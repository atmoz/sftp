import bcrypt
import sys


def main():
   print(f"hashing password: {sys.argv[1]}")
   password = sys.argv[1]
   salt = bcrypt.gensalt(10)
   hashed = bcrypt.hashpw(password.encode(), salt)
   print(f"hashed password: {hashed}")


if __name__ == "__main__":
    raise SystemExit(main())

