# DevOps Tools Installation Script

Automated Bash script for installing essential DevOps tools on Ubuntu/Debian systems.

Navigation

[Back to Main Project](https://github.com/LesiaUKR/my-microservice-project/tree/main) - Main project overview and navigation to all lessons

## What it installs

- **Docker** - Container platform for application deployment
- **Docker Compose** - Tool for defining multi-container applications  
- **Python 3.9+** - Programming language with pip package manager
- **Django** - Python web framework

## Features

- Checks if tools are already installed to avoid duplication
- Color-coded output for better readability
- Error handling and logging
- Verification of installed versions
- Compatible with Ubuntu/Debian distributions

## Usage

1. Make the script executable:
```bash
chmod u+x install_dev_tools.sh
```

2. Run the script:
```bash
./install_dev_tools.sh
```

## Requirements

- Ubuntu/Debian Linux system
- sudo privileges
- Internet connection

## Project Structure

```
my-microservice-project/
├── install_dev_tools.sh    # Main installation script
├── README.md              # Project documentation
└── .gitignore            # Git ignore file
```

## Technical Details

The script performs the following actions:

1. **System Update** - Updates package lists
2. **Docker Installation** - Adds official Docker repository and installs latest version
3. **Docker Compose Installation** - Downloads latest version from GitHub
4. **Python Installation** - Installs Python 3.9+ with pip
5. **Django Installation** - Installs Django via pip
6. **Verification** - Checks successful installation of all components

## Notes

- After Docker installation, you may need to log out and back in to use Docker without sudo
- The script automatically adds the user to the docker group
- All tools are installed from official sources




