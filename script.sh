#!/bin/bash

##### IP RANGE #####
ip=(
    "5.61.16.0/21"
    "5.61.232.0/21"
    "79.137.157.0/24"
    "79.137.174.0/23"
    "79.137.183.0/24"
    "94.100.176.0/20"
    "95.163.32.0/19"
    "95.163.212.0/22"
    "95.163.216.0/22"
    "95.163.248.0/21"
    "128.140.168.0/21"
    "178.22.88.0/21"
    "178.237.16.0/20"
    "178.237.29.0/24"
    "185.5.136.0/22"
    "185.16.148.0/22"
    "185.16.244.0/23"
    "185.16.246.0/24"
    "185.16.247.0/24"
    "188.93.56.0/21"
    "194.186.63.0/24"
    "195.211.20.0/22"
    "195.218.168.0/24"
    "217.20.144.0/20"
    "217.69.128.0/20"
    "109.70.27.44"
)

ip6=(
    "2a00:1148::/29"
    "2a00:1148::/32"
    "2a00:a300::/32"
    "2a00:b4c0::/32"
)
####################

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root!"
    exit
fi

clear

echo -e "\e[31mI'M NOT RESPONSIBLE FOR ANY DAMAGE WHAT-SO-EVER DONE TO YOUR IPTABLES!\e[0m"
echo
echo "Welcome to Mail.Ru Prefixes blocker for iptables."
echo "Type A to add rules to your iptables."
echo "Type D to delete rules from your iptables."
echo "Type any other to exit from this script."
read -p "Command [A/D]: " -r

echo "Starting process..."

function exit_script {
    echo -e "\e[2mDeveloped by Anonymous for https://t.me/zatelecom\e[0m"
    echo -e "\e[2mData from https://bgp.he.net/AS47764\e[0m"
    echo -e "\e[2mThis script updated on 24 April 2018\e[0m"
    exit
}

function add_rules {
    # IPv4 Set

    i_drop_all=0
    o_drop_all=0
    any=0
    all=0

    if iptables -S | grep -q -e "-A INPUT -j DROP"
    then
        echo "Found INPUT DROP ALL rule, deleting temporarily..."
        i_drop_all=1
        iptables -D INPUT -j DROP
        echo "INPUT DROP ALL rule deleted."
    fi

    if iptables -S | grep -q -e "-A OUTPUT -j DROP"
    then
        echo "Found OUTPUT DROP ALL rule, deleting temporarily..."
        o_drop_all=1
        iptables -D OUTPUT -j DROP
        echo "OUTPUT DROP ALL rule deleted."
    fi

    echo "Adding IP rules..."
    for item in ${ip[@]}
    do
        if ! iptables -S | grep -q -e "$item"
        then
            any=1
            all=1
            iptables -A INPUT -s $item -j DROP
            iptables -A OUTPUT -s $item -j DROP
            echo "$item added."
        else
            echo "$item exist. Skipping..."
        fi
    done

    if [ "$any" -eq "1" ]; then
        echo "IP rules added."
    else
        echo "Nothing to add."
    fi

    if [ "$i_drop_all" -eq "1" ]; then
        echo "Reverting INPUT DROP ALL rule..."
        iptables -A INPUT -j DROP
        echo "INPUT DROP ALL rule reverted."
    fi

    if [ "$o_drop_all" -eq "1" ]; then
        echo "Reverting OUTPUT DROP ALL rule..."
        iptables -A OUTPUT -j DROP
        echo "OUTPUT DROP ALL rule reverted."
    fi

    # IPv6 Set

    i_drop_all=0
    o_drop_all=0
    any=0

    echo "Checking IPv6 support..."
    if ip6tables --version
    then
        echo "Found ip6tables support, adding rules..."

        if ip6tables -S | grep -q -e "-A INPUT -j DROP"
        then
            echo "Found IPv6 INPUT DROP ALL rule, deleting temporarily..."
            i_drop_all=1
            ip6tables -D INPUT -j DROP
            echo "IPv6 INPUT DROP ALL rule deleted."
        fi

        if ip6tables -S | grep -q -e "-A OUTPUT -j DROP"
        then
            echo "Found IPv6 OUTPUT DROP ALL rule, deleting temporarily..."
            o_drop_all=1
            iptables -D OUTPUT -j DROP
            echo "IPv6 OUTPUT DROP ALL rule deleted."
        fi

        echo "Adding IPv6 rules..."
        for item in ${ip6[@]}
        do
            if ! ip6tables -S | grep -q -e "$item"
            then
                any=1
                all=1
                ip6tables -A INPUT -s $item -j DROP
                ip6tables -A OUTPUT -s $item -j DROP
                echo "$item added."
            else
                echo "$item exist. Skipping..."
            fi
        done

        if [ "$any" -eq "1" ]; then
            echo "IPv6 rules added."
        else
            echo "Nothing to add."
        fi

        if [ "$i_drop_all" -eq "1" ]; then
            echo "Reverting IPv6 INPUT DROP ALL rule..."
            ip6tables -A INPUT -j DROP
            echo "IPv6 INPUT DROP ALL rule reverted."
        fi

        if [ "$o_drop_all" -eq "1" ]; then
            echo "Reverting IPv6 OUTPUT DROP ALL rule..."
            ip6tables -A OUTPUT -j DROP
            echo "IPv6 OUTPUT DROP ALL rule reverted."
        fi
    fi

    if [ "$all" -eq "1" ]; then
        echo -e "\e[32mRules applied!\e[0m"
    else
        echo -e "\e[33mNothing to apply.\e[0m"
    fi

    echo
    echo -e "\e[33mDon't forget to save your rules permanently if you want so.\e[0m"
    echo

    exit_script
}

function delete_rules {
    all=0

    for item in ${ip[@]}
    do
        if iptables -S | grep -q -e "$item"
        then
            all=1
            iptables -D INPUT -s $item -j DROP
            iptables -D OUTPUT -s $item -j DROP
            echo "$item deleted."
        else
            echo "$item not found. Skipping..."
        fi
    done

    if ip6tables --version
    then
        echo "Found ip6tables support, deleting rules..."

        for item in ${ip6[@]}
        do
            if ip6tables -S | grep -q -e "$item"
            then
                all=1
                ip6tables -D INPUT -s $item -j DROP
                ip6tables -D OUTPUT -s $item -j DROP
                echo "$item deleted."
            else
                echo "$item not found. Skipping..."
            fi
        done
    fi

    if [ "$all" -eq "1" ]; then
        echo -e "\e[32mRules deleted!\e[0m"
    else
        echo -e "\e[33mNothing to delete.\e[0m"
    fi

    echo
    echo -e "\e[33mDon't forget to save your rules permanently if you want so.\e[0m"
    echo

    exit_script
}

case "$REPLY" in
"a" | "A")
    add_rules
    ;;
"d" | "D")
    delete_rules
    ;;
*)
    exit_script
    ;;
esac
