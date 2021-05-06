#! /usr/bin/python

from configparser import ConfigParser
import shlex

parser = ConfigParser()
with open("pir.conf") as stream:
    parser.read_string("[CONFIG]\n" + stream.read())

config=parser['CONFIG']

PIR_GPIO = config.getint("GPIO")
INTERNAL_RESISTOR = config.get("INTERNAL_RESISTOR", "off")
STOP_DELAY = int(config.get("DELAY", 10))
MAX_LENGTH = int(config.get("MAX_ON", 0))
COMMAND_ON = shlex.split(config.get("COMMAND_ON"))
COMMAND_OFF = shlex.split(config.get("COMMAND_OFF"))

import logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger("PIR Sensor")
logger.setLevel(logging.DEBUG)

import RPi.GPIO as GPIO
import time
import threading
import subprocess

if (INTERNAL_RESISTOR=="pull-down"):
  INTERNAL_RESISTOR=GPIO.PUD_DOWN
elif (INTERNAL_RESISTOR=="pull-up"):
  INTERNAL_RESISTOR=GPIO.PUD_UP
else:
  INTERNAL_RESISTOR=GPIO.PUD_OFF


class MotionWrapper:
  def __init__(self):
    self.mode="idle"
    self.timer=None
  
  def cleanup(self):
    if (self.timer):
      self.timer.cancel();
      self.timer=None;
    if (self.mode!="idle"):
      logger.debug("Cancel recording")
      self.recording_stop();

  def detected(self, motion):
    if (self.timer):
      self.timer.cancel();
      self.timer=None;

    if (motion):
      logger.info("Motion detected");
      self.mode="motion"
      self.recording_start()
    
      # Stop video at least after MAX_LENGTH seconds
      if (MAX_LENGTH > 0):
        self.timer=threading.Timer(MAX_LENGTH, self.recording_stop)
        self.timer.start()
    else:
      logger.info("No Motion detected");
      self.mode="nomotion"
      self.timer=threading.Timer(STOP_DELAY, self.recording_stop)
      self.timer.start()

  def recording_start(self):
    logger.info("Start")
    subprocess.check_output(COMMAND_ON)
   
  def recording_stop(self):
    logger.info("Stop")
    if (self.timer):
      self.timer.cancel();
    self.timer=None;

    subprocess.check_output(COMMAND_OFF)
    self.mode="idle"

motion=MotionWrapper()


# Signal handler
import signal
def handle_signals(signum, stack):
  logger.debug("Received signal {signal}".format(signal=signum))

# GPIO event callback
def callback_motion(channel):
  gpio_state = GPIO.input(PIR_GPIO)
  
  if (gpio_state):
    motion.detected(True)
  else:
    motion.detected(False)


def run():
  signal.signal(signal.SIGTERM, handle_signals)
  signal.signal(signal.SIGINT, handle_signals)

  GPIO.setmode(GPIO.BCM) # Use GPIO numbering
  GPIO.setup(PIR_GPIO, GPIO.IN, pull_up_down=INTERNAL_RESISTOR)

  GPIO.add_event_detect(PIR_GPIO,GPIO.BOTH,callback=callback_motion) 

  # Wait for exit
  signal.pause()
  
  global motion
  motion.cleanup()
  GPIO.cleanup()
  logger.debug("Bye")


if __name__ == "__main__":
  run()
