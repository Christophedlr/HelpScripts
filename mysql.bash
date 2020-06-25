#!/bin/bash

default="y"
root_password=""
username=""
database=""

function help()
{
  echo "Usage: mysql.bash [OPTION] [COMMAND]"
  echo "Manage database"
  echo ""
  echo "OPTION"
  echo "-p       Root password"
  echo ""
  echo "COMMAND"
  echo "cuser	   Create a new user"
  echo "duser    Delete a user"
  echo "cdb      Create a new database"
  echo "ddb      Delete a database"
}

function create_database()
{
  sql=""

  read -p "Name of database: " database
  echo ""
  sql="CREATE DATABASE IF NOT EXISTS $database;"
  echo "Create database $database"

  read -p "Grant all privileges for an user ? [Y/n]" -n 1 grant
  grant="${grant:-${default}}"
  echo ""
  
  if [ "$grant" = "y" ]; then
    read -p "Name of valid user: " username

    sql="$sql GRANT ALL PRIVILEGES ON $database.* to '$username'@localhost;"
    echo "Grant database $database for $username"
  fi

  sql="$sql FLUSH PRIVILEGES;"
  mysql -u root --password=$root_password -e "$sql"
}

function drop_database()
{
  sql=""

  read -p "Name of database for delete: " database
  echo ""
  sql="DROP DATABASE IF EXISTS $database;"
  echo "delete database $database"

  read -p "Revoke all privileges for an user of database ? [Y/n]" -n 1 grant
  grant="${grant:-${default}}"
  echo ""

  if [ "$grant" = "y" ]; then
    read -p "Name of valid user: " username

    sql="$sql REVOKE ALL PRIVILEGES ON $database.* to '$username'@localhost;"
    echo "Grant database $database for $username"
  fi

  sql="$sql FLUSH PRIVILEGES;"
  mysql -u root --password=$root_password -e "$sql"
}

function create_user()
{
  read -p "Enter a new username: " username
  read -p "Enter a new password: " -s password
  echo ""
  read -p "Enter a new password confirmation: " -s password_confirmation
  echo ""
  read -p "Grant global all privileges ? [Y/n]" -n 1 grant_global
  grant_global="${grant_global:-${default}}"
  echo ""

  if [ -z "$password" ] || [ -z "$password_confirmation" ] || [ "$password" != "$password_confirmation" ]; then
      echo "Passwords not mismatch or is empty"
      exit
  fi
  
  sql_user="CREATE USER '$username'@localhost IDENTIFIED BY '$password';"

  if [ "$grant_global" = "y" ]; then
      sql_user="$sql_user GRANT ALL PRIVILEGES ON *.* TO '$username'@localhost WITH GRANT OPTION;"
  fi

  echo "Created user $username"

  mysql -u root --password=$root_password -e "${sql_user}FLUSH PRIVILEGES;"


  read -p "Create user database ? [Y/n]" -n 1 create_database
  create_database="${create_database:-${default}}"
  echo ""
  
  if [ "$create_database" = "y" ]; then
      echo "Created database $username for $username user"

      mysql -u root --password=$root_password -e "CREATE DATABASE $username;GRANT ALL PRIVILEGES ON $username.* to '$username'@localhost;FLUSH PRIVILEGES;"
  fi
}

function drop_user()
{
  read -p "Enter a username at deleted: " username

  echo "Remove user $username"
  mysql -u root --password=$root_password -e "DROP DATABASE IF EXISTS $username; DROP USER IF EXISTS '$username'@localhost; FLUSH PRIVILEGES;"
}

while getopts "p:" option; do
  case $option in
      p)
          root_password=$OPTARG
          ;;
  esac
done
shift $((OPTIND-1))

if [ $# -lt 1 ]; then
  help
  exit
fi

echo "Bash MySQL utility"

if [ -z $root_password ]; then
  read -p "Enter a root password: " -s root_password
fi

if [ $1 = "cuser" ]; then
  create_user
elif [ $1 = "duser" ]; then
  drop_user
elif [ $1 = "cdb" ]; then
  create_database
elif [ $1 = "ddb" ]; then
  drop_database
fi
