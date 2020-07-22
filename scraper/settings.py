import os
from dotenv import load_dotenv

load_dotenv()

user = os.getenv("user")
password = os.getenv("password")
urlLogin = 'https://www.linkedin.com/login'
urlSearch = 'https://www.linkedin.com/jobs/search/?f_T=340%2C2732%2C25189%2C25190%2C25206&location=Spain'
chromeDriver = 'C:\\ProgramData\\chromedriver.exe'
