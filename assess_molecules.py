import sys
import os
import pandas as pd
import numpy as np
from scipy.stats import bootstrap
from posebusters import PoseBusters

def process_file(file_path):
    print(f"Processing file: {file_path}")
    buster = PoseBusters(config="mol")
    df = buster.bust([file_path], None, None)

    # Columns to analyze
    columns_to_analyze = [
        "sanitization",
        "all_atoms_connected",
        "bond_lengths",
        "bond_angles",
        "internal_steric_clash",
        "aromatic_ring_flatness",
        "double_bond_flatness",
        "internal_energy",
    ]

    # Add a column to check if all tests are True for each row
    df["all_tests"] = df[columns_to_analyze].all(axis=1)

    # Initialize results dictionary
    results = {}

    # Analyze each column
    for column in columns_to_analyze:
        # Drop NaN values for this column
        valid_values = df[column].dropna().astype(bool)

        # Calculate the pass percentage
        pass_percentage = valid_values.mean() * 100

        # Calculate 95% confidence interval using bootstrap
        confidence_interval = bootstrap(
            (valid_values.values,), 
            np.mean, 
            confidence_level=0.95, 
            method='percentile', 
            random_state=42
        ).confidence_interval

        # Store results
        results[column] = {
            "pass_percentage": pass_percentage,
            "confidence_interval": (confidence_interval.low * 100, confidence_interval.high * 100)
        }

    # Add all_tests to the results
    all_tests_passed = df["all_tests"].mean() * 100
    all_tests_ci = bootstrap(
        (df["all_tests"].astype(bool).values,), 
        np.mean, 
        confidence_level=0.95, 
        method='percentile', 
        random_state=42
    ).confidence_interval
    results["all_tests"] = {
        "pass_percentage": all_tests_passed,
        "confidence_interval": (all_tests_ci.low * 100, all_tests_ci.high * 100)
    }

    # Create a DataFrame for the results
    formatted_results = {
        column: f"{stats['pass_percentage']:.1f} ({stats['confidence_interval'][0]:.1f}–{stats['confidence_interval'][1]:.1f})"
        for column, stats in results.items()
    }

    # Convert to a single-row DataFrame
    results_df = pd.DataFrame([formatted_results], index=["Metrics"])

    # Save the DataFrame to a CSV file in the same directory as the input file
    output_file_path = os.path.join(os.path.dirname(file_path), "assessment_results.csv")
    results_df.to_csv(output_file_path)
    print(f"Results saved to {output_file_path}")

    # Print the DataFrame
    print(results_df)

def main(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".sdf"):
                file_path = os.path.join(root, file)
                process_file(file_path)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python assess_molecules.py <directory>")
        sys.exit(1)
    
    directory = sys.argv[1]
    main(directory)

