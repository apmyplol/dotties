""" Script to Download Anime Episodes from Proxer.me """

import os
import sys
import time
import logging
import re
import concurrent.futures as cf
from datetime import datetime
from configparser import ConfigParser
from re import search

import requests
from bs4 import BeautifulSoup, SoupStrainer
import tqdm
from cloudscraper import CloudScraper

AUTHFILE = "login.auth"

HEADERS = requests.utils.default_headers()
'''
old headers 
HEADERS.update(
    {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36", })
'''

HEADERS.update({"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36"})

if os.name == "nt":
    SLASH = "\\"
else:
    SLASH = "/"
CWD = os.path.dirname(os.path.realpath(__file__)) + SLASH

LOGGER = logging.getLogger('plme.main')
LOG_FORMAT = "%(asctime)-15s | %(levelname)s | %(module)s %(name)s %(process)d %(thread)d | %(funcName)20s() - Line %(lineno)d | %(message)s"
LOGGER.setLevel(logging.DEBUG)
STRMHDLR = logging.StreamHandler(stream=sys.stdout)
STRMHDLR.setLevel(logging.INFO)
STRMHDLR.setFormatter(logging.Formatter(LOG_FORMAT))
LOGGER.addHandler(STRMHDLR)

LIMIT = 5
SESSION = requests.Session()
EXECUTOR = cf.ThreadPoolExecutor(LIMIT)


def init_preps(link = None, startep = None, endep = None):
    """ Function to log in and initiate the Download Process """

    config = ConfigParser()
    try: # safely try to read login credentials and log into proxer
        config.read(AUTHFILE)
        #user = config["LOGIN"]["USER"]
        #passwd = config["LOGIN"]["PASS"]
        user = "SmokeArts"
        passwd = "nyandanyo"
        #LOGGER.info(f"{user}|{passwd}")
        scraper = CloudScraper() # use Cloudscraper to bypass Cloudflares Redirection Page
        prourl = "https://proxer.me"
        resp = scraper.get(prourl) # grab the main page
        strainer = SoupStrainer(id="loginBubble") # restrict to login related html using a strainer
        soup = BeautifulSoup(resp.content, "html.parser", parse_only=strainer) # use the strainer to restrict parsing
        url = soup.find("form")["action"] # grab the login url
        creds = {"username": user, "password": passwd, "remember": 1} # set credentials (remember is irrelevant, due to this being a singular session)
        resp2 = SESSION.post(prourl + url, data=creds) # hopefully logged in correctly

    except Exception as excp:
        LOGGER.exception(excp)
        LOGGER.warning(f"Something went wrong during Login!\nExiting...")
        sys.exit(1)

    firstepisode = 1
    lastepisode = 2
    inputurl = "http://proxer.me/info/277/"
    if not (link == None and startep == None and endep == None):
        inputurl = link
        firstepisode = int(startep) or 1
        lastepisode = int(endep) or 1
    else:
        LOGGER.info("Recommended URL-Format would be: http://proxer.me/info/277/\n")
        inputurl = input("Please enter the URL of the Anime you want to download: ")
        #inputurl = "https://proxer.me/info/6587"#cm
        firstepisode = int(
            input("Please enter the Number of the first Episode you want: ") or 1)
        lastepisode = int(
            input("Please enter the Number of the last Episode you want: ") or 1)

    #print("first ep is " + str(firstepisode))
    #print("last ep is " + str(lastepisode))
    if lastepisode < firstepisode: # check for fishy episode requests
        lastepisode = firstepisode
    resp = SESSION.get(inputurl) # grab the anime page
    strainer = SoupStrainer(class_="fn") # let's restrict the area for our name search, to the exact element
    soup = BeautifulSoup(resp.content, "html.parser", parse_only=strainer)
    name = soup.string.replace(":", "-") # win compat qwq

    match = search("#.*", inputurl) # check if the url contains unwanted resource descriptors
    if match is None:
        match = ""
    else:
        match = match[0] # there's a reason behind the urls scheme recommendation, if there's more than 1 match user should learn to read
    inputurl = inputurl.strip(match).replace("info", "watch") # make sure it's the correct url (lazy)
    if inputurl[-1:] != "/": # verify that "/" is the last char
        inputurl = f"{inputurl}/"
    try:
        futurelist = []
        for episodenum in range(firstepisode, lastepisode + 1):
            episodeurl = f"{inputurl}{episodenum}/engsub" # force the scrubs to enjoy engsub
            #LOGGER.debug(episodeurl)
            #LOGGER.debug(f"Creating Worker for Episode {episodenum}")
            futurelist.append(EXECUTOR.submit(retrieve_source, episodeurl, name, episodenum))

        for future in cf.as_completed(futurelist): # check for thread status
            try:
                video = future.done() # cf equivalent of threading.Thread.join()
                #LOGGER.debug(f"Worker for Episode {episodenum} returned: {video}")
            except Exception as excp:
                LOGGER.exception(f"{supposed_video} has thrown Exception:\n{excp}")
                sys.exit(1)
    except BaseException as excp:
        LOGGER.exception(f"{excp}")
        sys.exit(1)


def retrieve_source(episodeurl, name, episodenum):
    """ Function to make all the Magic happen, parses the streamhoster url [Proxer] and parses the video url """
    try: # if anything fails in here, it's prolly the captcha
        #LOGGER.info(f"{episodeurl}, {name}, {episodenum}")
        streamhosterurl = None
        resp = SESSION.get(episodeurl, timeout=30) # grab the specific episode
        out = ""
        for line in resp.text.split("\n"):
            if "var streams" in line:
                #LOGGER.info(line.split("[{")[1].split("}];")[0].split("},{"))
                for streamhoster in line.split("[{")[1].split("}];")[0].split("},{"): # parses all available stream hoster
                    elem = streamhoster.split("code\":\"")[1].split("\",\"img\"")[0].replace("//", "").replace(r"\/", "/").replace("\":\"", "\",\"").split("\",\"")
                    code = str(elem[0])
                    baseurl = f"{elem[8]}".replace("#", code)
                    if "http" not in baseurl:
                        baseurl = f"http://{baseurl}"
                    #LOGGER.info(f"Streamurls: {baseurl}")
                    if "proxer" in baseurl: # we'll just use proxer tho
                        streamhosterurl = baseurl
        #LOGGER.info(f"Streamhoster: {streamhosterurl}")

        if streamhosterurl == None:
            print("NO URL ERROR1")
            os._exit(1)

        resp2 = SESSION.get(streamhosterurl, timeout=30) # grabbing the page where the video is embedded in

        for line in resp2.text.split("\n"):
            if "\"http" and ".mp4\"" in line: # parsing the video url from that half-crappy js
                streamurl = f"http{line.split('http')[1].split('.mp4')[0]}.mp4"
                episodename = f"{name}_Episode_{episodenum}"
                out += streamurl + " " + episodename.replace(" ", "_") + "\n"
                #sys.stdout.write(streamurl + "^" + episodename+ "\n")
                sys.stdout.write(streamurl + " " + episodename.replace(" ", "_") + "\n")
                #LOGGER.info(f"Streamurl: {streamurl}")
                if streamurl == "": # verify this check!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
                    LOGGER.error("NOURL Error2")
                    sys.exit(1)

        #sys.stdout.write(out)
        sys.stdout.flush()
    except BaseException as excp:
        LOGGER.exception(f"{excp}")
        sys.exit(1)

if __name__ == "__main__": # main guard
    """ MAIN """
    try:
        if len(sys.argv) == 4:
            init_preps(sys.argv[1], sys.argv[2], sys.argv[3])
        else:
            init_preps()
    except BaseException as excp:
        LOGGER.exception(f"{excp}")
        sys.exit(1)