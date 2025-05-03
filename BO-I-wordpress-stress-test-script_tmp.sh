#!/bin/bash
# BO I WordPress JMeter Stress Test Script

# Configuration
HOST="localhost"
TEST_PLAN="BO I - WordPress Load Test"
RESULTS_DIR="./results"
LOG_FILE="$RESULTS_DIR/jmeter.log"
REPORT_DIR="$RESULTS_DIR/report"
DURATION=300  # Test duration in seconds
RAMP_UP=60    # Ramp-up period in seconds

# Create results directory if it doesn't exist
mkdir -p $RESULTS_DIR
mkdir -p "$REPORT_DIR/basic" "$REPORT_DIR/high" "$REPORT_DIR/spike" "$REPORT_DIR/endurance"

# Update the test plan with your site's details
echo "Updating test plan with your site details..."
sed -i "s/example\.com/$HOST/g" $TEST_PLAN

# Basic test - moderate load
function run_basic_test() {
    echo "Running basic load test..."
    jmeter -n -t $TEST_PLAN \
        -Jhost=$HOST \
        -Jthreads.basic=50 \
        -Jthreads.search=20 \
        -Jthreads.comment=15 \
        -Jthreads.admin=5 \
        -Jthreads.category=30 \
        -Jthreads.form=10 \
        -Jrampup=$RAMP_UP \
        -Jduration=$DURATION \
        -l "$RESULTS_DIR/basic_test_results.jtl" \
        -j "$LOG_FILE" \
        -e -o "$REPORT_DIR/basic"
}

# High load test
function run_high_load_test() {
    echo "Running high load test..."
    jmeter -n -t $TEST_PLAN \
        -Jhost=$HOST \
        -Jthreads.basic=200 \
        -Jthreads.search=100 \
        -Jthreads.comment=50 \
        -Jthreads.admin=10 \
        -Jthreads.category=150 \
        -Jthreads.form=50 \
        -Jrampup=$RAMP_UP \
        -Jduration=$DURATION \
        -l "$RESULTS_DIR/high_load_results.jtl" \
        -j "$LOG_FILE" \
        -e -o "$REPORT_DIR/high"
}

# Spike test
function run_spike_test() {
    echo "Running spike test..."
    jmeter -n -t $TEST_PLAN \
        -Jhost=$HOST \
        -Jthreads.basic=300 \
        -Jthreads.search=150 \
        -Jthreads.comment=75 \
        -Jthreads.admin=15 \
        -Jthreads.category=200 \
        -Jthreads.form=75 \
        -Jrampup=10 \     # Short ramp-up for spike
        -Jduration=120 \  # Shorter duration for spike
        -l "$RESULTS_DIR/spike_results.jtl" \
        -j "$LOG_FILE" \
        -e -o "$REPORT_DIR/spike"
}

# Endurance test - lower load but longer duration
function run_endurance_test() {
    echo "Running endurance test..."
    jmeter -n -t $TEST_PLAN \
        -Jhost=$HOST \
        -Jthreads.basic=40 \
        -Jthreads.search=15 \
        -Jthreads.comment=10 \
        -Jthreads.admin=3 \
        -Jthreads.category=25 \
        -Jthreads.form=8 \
        -Jrampup=120 \        # Longer ramp-up
        -Jduration=1800 \     # 30 minutes test
        -l "$RESULTS_DIR/endurance_results.jtl" \
        -j "$LOG_FILE" \
        -e -o "$REPORT_DIR/endurance"
}

# Display menu and handle user choice
function display_menu() {
    clear
    echo "==============================================="
    echo "        WordPress JMeter Stress Test Tool      "
    echo "==============================================="
    echo "1. Run Basic Load Test (Moderate Load)"
    echo "2. Run High Load Test"
    echo "3. Run Spike Test"
    echo "4. Run Endurance Test (30 minutes)"
    echo "5. Run All Tests"
    echo "6. View Results Summary"
    echo "7. Clean Results Directory"
    echo "8. Exit"
    echo "==============================================="
    read -p "Enter your choice [1-8]: " choice
    
    case $choice in
        1) run_basic_test ;;
        2) run_high_load_test ;;
        3) run_spike_test ;;
        4) run_endurance_test ;;
        5) 
            run_basic_test
            echo "Waiting 60 seconds before next test..."
            sleep 60
            run_high_load_test
            echo "Waiting 60 seconds before next test..."
            sleep 60
            run_spike_test
            echo "Waiting 60 seconds before next test..."
            sleep 60
            run_endurance_test
            ;;
        6) view_results ;;
        7) 
            read -p "Are you sure you want to clean results directory? (y/n): " confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                rm -rf $RESULTS_DIR/*
                mkdir -p "$REPORT_DIR/basic" "$REPORT_DIR/high" "$REPORT_DIR/spike" "$REPORT_DIR/endurance"
                echo "Results directory cleaned."
            fi
            ;;
        8) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
    display_menu
}

# View results summary
function view_results() {
    echo "==============================================="
    echo "              Results Summary                  "
    echo "==============================================="
    
    if [ -f "$RESULTS_DIR/basic_test_results.jtl" ]; then
        echo "Basic Test Results:"
        echo "Report available at: $REPORT_DIR/basic/index.html"
        echo "Average response time: $(awk -F, '{sum+=$1; count++} END {print sum/count " ms"}' "$RESULTS_DIR/basic_test_results.jtl")"
        echo
    fi
    
    if [ -f "$RESULTS_DIR/high_load_results.jtl" ]; then
        echo "High Load Test Results:"
        echo "Report available at: $REPORT_DIR/high/index.html"
        echo "Average response time: $(awk -F, '{sum+=$1; count++} END {print sum/count " ms"}' "$RESULTS_DIR/high_load_results.jtl")"
        echo
    fi
    
    if [ -f "$RESULTS_DIR/spike_results.jtl" ]; then
        echo "Spike Test Results:"
        echo "Report available at: $REPORT_DIR/spike/index.html"
        echo "Average response time: $(awk -F, '{sum+=$1; count++} END {print sum/count " ms"}' "$RESULTS_DIR/spike_results.jtl")"
        echo
    fi
    
    if [ -f "$RESULTS_DIR/endurance_results.jtl" ]; then
        echo "Endurance Test Results:"
        echo "Report available at: $REPORT_DIR/endurance/index.html"
        echo "Average response time: $(awk -F, '{sum+=$1; count++} END {print sum/count " ms"}' "$RESULTS_DIR/endurance_results.jtl")"
        echo
    fi
}

# Check if JMeter is installed
if ! command -v jmeter &> /dev/null; then
    echo "JMeter is not installed or not in your PATH."
    echo "Please install JMeter and try again."
    exit 1
fi

# Check if test plan exists
if [ ! -f "$TEST_PLAN" ]; then
    echo "Error: Test plan file ($TEST_PLAN) not found."
    echo "Please make sure the JMX file exists in the current directory."
    exit 1
fi

# Start the program
display_menu