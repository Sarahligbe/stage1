# Stage 1 task
## Details
As a SysOps engineer, you have been tasked to write a bash script that creates a Users, Groups, and home directories with appropriate permissions for new employees in your company

## Solution
Read my [article](https://dev.to/sarahligbe/user-management-automation-in-linux-using-bash-script-197l) for the detailed solution

## Usage
1. Clone this repository on your Ubuntu machine using:
```bash
git clone <repo-link>
```
2. Execute the file by running 
```bash
sudo chmod +x create_users.sh
```
3. Ensure you have an input file ready as it an argument to run the script. Your input file should be in the format below:
```bash
light; sudo,dev,www-data
idimma; sudo
mayowa; dev,www-data
```
Usernames and user groups are separated by semicolon ";"- Ignore whitespace. A user can have multiple groups, each group delimited by a comma. 

save the input file by whatever name you prefer, e.g., `input.txt`. 

4. Run the script. Ensure your user has sudo privileges before running:
```bash
bash create_users.sh input.txt
```


