
// This #include statement was automatically added by the Particle IDE.
#include <Adafruit_DHT.h>
// This #include statement was automatically added by the Particle IDE.
#include <ThingSpeak.h>
// This #include statement was automatically added by the Particle IDE.
#include <neopixel.h>
// This #include statement was automatically added by the Particle IDE.

TCPClient client;
#include "Particle.h"
#include "IOP.h"

//#include "neopixel.h"

SYSTEM_MODE(SEMI_AUTOMATIC);
//SYSTEM_MODE(AUTOMATIC);

boolean connectToCloud = false;
SYSTEM_THREAD(ENABLED);
STARTUP(WiFi.setListenTimeout(6)); // Set max time to listen for new WiFi credentials.

/////////////Pins/////////////////////
// IMPORTANT: Set pixel COUNT, PIN and TYPE
#define PIXEL_PIN A2
#define PIXEL_COUNT 40
#define PIXEL_TYPE WS2812

DHT dht(D3, DHT22);
// int getLastReadStatus;

const int photoCell = A5;
const int power1 = D6; // Photocell power.  An analog pin to gives a more steady voltage.
//const int power2 = D1; // Photocell power.  An analog pin to gives a more steady voltage.

const int Moisture = A0;

/////////////Button/////////////
const int BUTTON = D7;            // our button pin
unsigned long buttonPushedMillis; // when button was released
//unsigned long ledTurnedOnAt;       // when led was turned on
unsigned long turnOnDelay = 100;  // wait to turn on LED
unsigned long turnOffDelay = 100; // turn off LED after this time
bool ledReady = false;            // flag for when button is let go
//bool ledState = false;             // for LED is on or not.
unsigned int lastbuttonvalue = 0;    // previous state of the button
unsigned int currentbuttonvalue = 0; // current state of the button

unsigned int buttonPushCounter = 0; // counter for the number of button presses
unsigned int lastbuttonCounter = 0;
//int buttonState = 0;         // current state of the button
//int lastButtonState = 0;     // previous state of the button

/////////read///////////
unsigned long readMillis = 0;     // how long till the last read and speak
unsigned long previousMillis = 0; // how long till the last senor real (only for sensors delays)
unsigned long speakMillis = 0;
unsigned long read1 = 2000;
unsigned long read2 = 4000;
unsigned long read3 = 6000;
unsigned long read4 = 15000;

//////////////Light/////////////////
Adafruit_NeoPixel strip(PIXEL_COUNT, PIXEL_PIN, PIXEL_TYPE);

// thingspeak channel no and key are set in IOP.h
unsigned long myChannelNumber = CHANNELNO; /*Thingspeak channel id*/
const char *myWriteAPIKey = WRITEKEY;      /*Channel's write API key*/
//unsigned long myChannelNumber = 443542;         /*Thingspeak channel id*/
//const char *myWriteAPIKey = "4V4UQ5VL59D22LNR"; /*Channel's write API key*/
unsigned int LowLight = LOWLIGHT;
///////////Global variables//////////////////
int light;          // Light
unsigned int moist; // Light
int mmoist;
// int moistbar;
float h;
float f;
float c;
unsigned long SleepPeriod = SLEEPTIME;
unsigned long ReadTime = READFREQ;

////// Checklist//////
bool reading = false; // check if done reading
bool rsoil = false;
bool rtemp = false;
bool rlight = false;
bool SleepMode = SLEEPMODE; // sleep period, defined in IOP.h

//DHT dht(DHTPIN, DHTTYPE);
unsigned int loopCount;

const int setupPin = A3;
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void setup()
{
    pinMode(BUTTON, INPUT_PULLUP);
    pinMode(setupPin, INPUT_PULLUP);

    ThingSpeak.begin(client);
    dht.begin();

    pinMode(photoCell, INPUT);

    pinMode(Moisture, INPUT);

    pinMode(power1, OUTPUT);
    digitalWrite(power1, HIGH); // Turn on power source for photoCell

    // pinMode(power2, OUTPUT);
    //digitalWrite(power2, HIGH); // Turn on power source for photoCell

    loopCount = 0;
    delay(2000);

    strip.begin();
    strip.show(); // Initialize all pixels to 'off'
    //read();
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void loop()
{        Particle.connect();

    /*    
    if (last == 200){

        strip.setPixelColor(2, 0, 1, 0);
                 strip.show();


    
    }else{
                strip.setPixelColor(2, 1, 1, 1);
            strip.show();

    }*/

    if (reading == false)
    {
        //connect();
        read();
    }

    if (digitalRead(setupPin) == LOW)
    {

        strip.setPixelColor(32, 1, 0, 0);
        strip.show();

        delay(3000);
        if (digitalRead(setupPin) == LOW)
        {
            WiFi.listen();
        }
        else
        {
            strip.setPixelColor(32, 0, 0, 0);
            strip.show();
        }
    }
    ////////Imoprtant TODO//////////////////////////
    //////turn off the grow light before reading sensor data
    //reading = false;

    // get the time at the start of this loop()

    unsigned long currentMillis = millis();
    currentbuttonvalue = digitalRead(BUTTON);

    // compare the buttonState to its previous state
    if (currentbuttonvalue != lastbuttonvalue)
    {
        // if the state has changed, increment the counter
        if (currentbuttonvalue == LOW)
        {
            // if the current state is HIGH then the button went from off to on:
            buttonPushCounter++;
            //Serial.println("on");
            //Serial.print("number of button pushes: ");
            //Serial.println(buttonPushCounter);
        }
    }
    // save the current state as the last state, for next time through the loop
    lastbuttonvalue = currentbuttonvalue;

    // Delay a little bit to avoid bouncing
    //  delay(50);

    /* // check the button
  if (digitalRead(BUTTON) == LOW)
  {
    // update the time when button was pushed
    buttonPushedMillis = currentMillis;
    ledReady = true;

  }

  // make sure this code isn't checked until after button has been let go
  if (ledReady)
  {
    //this is typical millis code here:
    if ((unsigned long)(currentMillis - buttonPushedMillis) >= turnOnDelay)
    {
      // okay, enough time has passed since the button was let go.

      // save when the LED turned on
      // ledTurnedOnAt = currentMillis;
      // wait for next button press
      ledReady = false;
                currentbuttonvalue++;

    }
  }
*/
    // see if we are watching for the time to turn off LED
    /*if (ledState)
  {
    // okay, led on, check for now long
    if ((unsigned long)(currentMillis - ledTurnedOnAt) >= turnOffDelay)
    {
      //ledState = false;
      //digitalWrite(LED, LOW);
    }
  }*/

    //  Particle.publish("state", "switch started");

    if (buttonPushCounter != lastbuttonCounter || (currentMillis - readMillis) >= ReadTime)
    {
        //previousMillis = currentMillis;
        //reading = false;
        //         Particle.publish("state", "switch");
        //  Particle.publish("currentMillis", String(currentMillis));
        ///  Particle.publish("readMillis", String(readMillis));
        //  Particle.publish("buttonPushCounter", String(buttonPushCounter));
        //  Particle.publish("lastbuttonCounter", String(lastbuttonCounter));

        switch (buttonPushCounter)
        {
        case 0:

            read();
            Particle.publish("state", "case 0");
            Particle.publish("button value", String(buttonPushCounter));
            //  read();

            break;
        case 1:

            if ((currentMillis - readMillis) >= ReadTime)
            {
                Particle.publish("state", "old reading");

                read();
                grow();
            }
            else
            {
                grow();
            }

            Particle.publish("state", "case 1");
            Particle.publish("button value", String(buttonPushCounter));
            //  read();
            break;
        case 2:
            if ((currentMillis - readMillis) >= ReadTime)
            {
                Particle.publish("state", "old reading");

                //read();
                autog();
            }
            else
            {
                autog();
            }
            Particle.publish("state", "case 2");
            Particle.publish("button value", String(buttonPushCounter));
            break;
        case 3: // bars
            if ((currentMillis - readMillis) >= ReadTime)
            {
                Particle.publish("state", "old reading");

                read();
                bars();
            }
            else
            {

                bars();
            }

            Particle.publish("state", "case 3");
            Particle.publish("button value", String(buttonPushCounter));

            break;
        case 4:
            if ((currentMillis - readMillis) >= ReadTime)
            {
                Particle.publish("state", "old reading");

                read();
                moodone();
            }
            else
            {
                moodone();
            }
            Particle.publish("state", "case 4");
            Particle.publish("button value", String(buttonPushCounter));

            break;
        case 5:
            if ((currentMillis - readMillis) >= ReadTime)
            {
                Particle.publish("state", "old reading");

                read();
                moodtwo();
            }
            else
            {
                moodtwo();
            }
            Particle.publish("state", "case 5");
            Particle.publish("button value", String(buttonPushCounter));

            break;
        default:
            if ((currentMillis - readMillis) >= ReadTime)
            {
                Particle.publish("state", "old reading");

                read();
                buttonPushCounter = 0;
            }
            else
            {
                uint16_t i;
                uint16_t q;

                for (i = 0; i < 40; i++)
                {
                    strip.setPixelColor(i, 0, 0, 0);
                }
                strip.show();
                Particle.publish("state", "grrow light off read");
                buttonPushCounter = 0;
            }
            Particle.publish("state", "case DD");
            Particle.publish("button value", String(buttonPushCounter));
            break;
        }
        lastbuttonCounter = buttonPushCounter;
        // lastbuttonvalue = currentbuttonvalue;
    }

    /////////// check cloude connection
     if (connectToCloud && Particle.connected() == false)
    {
        //Particle.publish("State", "loop connect1");

        Particle.connect();
        connectToCloud = false;
    }
    else{
           connect(); 
           }
    // Particle.publish("State", "loop connect2");

    //	String timeStamp = Time.timeStr();
    //connect();

    //////////////////////////Deep sleep/////////////////////////////////////////
    /*if (reading == true){
        Particle.disconnect();
        reading == false;

}*/
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void connect()
{
    connectToCloud = true;
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void read()
{

    unsigned long currentMillis = millis();

    //reading = false; // didn't read yet
    uint16_t i;
    uint16_t q;

    for (i = 0; i < 1; i++)
    {
        strip.setPixelColor(i, 0, 0, 1);
    }
    strip.show();
    Particle.publish("state", "grrow light off read");
    //previousMillis = currentMillis;

    Particle.publish("state", "Reading");

    /////////////////////temp////////////////////////////

    // is this needed?
    // Reading temperature or humidity takes about 250 milliseconds!
    // Sensor readings may also be up to 2 seconds 'old' (its a
    // very slow sensor)

    delay(1000),
        h = dht.getHumidity();
    Particle.publish("state", "Humidiy done");

    // Read temperature as Celsius
    c = dht.getTempCelcius();
    // Read temperature as Farenheit
    f = dht.getTempFarenheit();
    Particle.publish("state", "temp done");

    Particle.publish("f", String(h));
    Particle.publish(" f", String(f));

    /////////////////////light/////////////////////

    delay(1000),

        light = analogRead(photoCell);
    // previousMillis = currentMillis;

    // String light1 = String(light);
    Particle.publish("state", "light done");
    //Particle.publish("light value", String(light));
    //previousMillis = currentMillis;

    /////////////////moist//////////////////////
    delay(1000),

        moist = analogRead(Moisture);
    mmoist = map(moist, 1921, 3344, 100, 0);
    //moistbar = map(moist)

    //previousMillis = currentMillis;
    // String light1 = String(light);
    delay(1000),

        Particle.publish("state", "Moituer done");
    Particle.publish("soil value", String(moist));
    Particle.publish("maaaaaaaaaapeppppped", String(mmoist));

    reading = true;
    Particle.publish("state", String(reading));
    delay(1000);
    Particle.publish("state", " done Reading");
    // previousMillis = currentMillis;

    ///////////////read millis//////////////

    if (reading == true)
    {
        for (i = 0; i < 1; i++)
        {
            strip.setPixelColor(i, 0, 0, 0);
        }
        strip.show();
        //speak();

        Particle.publish("state", "reading done");

        readMillis = currentMillis;
        //delay(1000);
        // Particle.connect();
        //delay(1000);
        speak();
    }
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void speak()
{
    int last = ThingSpeak.getLastReadStatus();

    uint16_t i;
    uint16_t q;
    for (i = 0; i < 1; i++)
    {
        strip.setPixelColor(i, 0, 1, 0);
        strip.show();
    }
    //delay(1000);

    //unsigned long currentMillis = millis();
    // speakMillis = currentMillis;

    //Particle.connect();
    //  if ((unsigned long)(currentMillis - speakMillis) >= readMillis)
    //   {
    ThingSpeak.setField(1, h);      // humidity
    ThingSpeak.setField(2, f);      //  temperature as Farenheit
    ThingSpeak.setField(3, light);  // light
    ThingSpeak.setField(4, mmoist); // soil moisture
    //Particle.connect();

    // Write the fields that you've set all at once.
    ThingSpeak.writeFields(myChannelNumber, myWriteAPIKey);
    delay(1000);

    //Particle.publish("state", "Published to thingspeak");
    // String last = getLastReadStatus;

    /*delay(1000);
          for (i = 0; i < 1; i++)
    {
        strip.setPixelColor(i, 0, 0, 0);
            strip.show();

    }*/

    Particle.publish("thing state", String(last));
    if (last != 200)
    {
        for (i = 0; i < 1; i++)
        {
            strip.setPixelColor(i, 1, 0, 0);
            strip.show();
        }
    }
    // speakMillis = currentMillis;
    //  }
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void temp()
{

    // delay(2000); // is this needed?
    // Reading temperature or humidity takes about 250 milliseconds!
    // Sensor readings may also be up to 2 seconds 'old' (its a
    // very slow sensor)
    h = dht.getHumidity();
    Particle.publish("state", "Humidiy done");

    // Read temperature as Celsius
    //	float t = dht.getTempCelcius();
    // Read temperature as Farenheit
    f = dht.getTempFarenheit();
    Particle.publish("state", "temp done");

    Particle.publish("f", String(h));
    Particle.publish(" f", String(f));
    // Check if any reads failed and exit early (to try again).
    /* if (isnan(h) || isnan(f)) {
		//Serial.println("Failed to read from DHT sensor!");
				Particle.publish("Failed to read from DHT sensor!");

		return;
	}
*/
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void photo()
{

    //delay(2000);
    light = analogRead(photoCell);
    // String light1 = String(light);
    Particle.publish("state", "light done");
    Particle.publish("light value", String(light));

    //delay(2000); // is this needed?
}
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void soil()
{
    moist = analogRead(Moisture);
    mmoist = map(moist, 1921, 3344, 100, 0);
    // String light1 = String(light);
    Particle.publish("state", "Moituer done");
    Particle.publish("soil value", String(moist));
    // delay(1000);
    Particle.publish("maaaaaaaaaapeppppped", String(mmoist));
    //delay(1000);
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void grow()
{
    // Particle.publish("thing state", String(getLastReadStatus));

    uint16_t i;
    uint16_t q;
    // uint16_t j;

    //   for (q = 0, j = 0; j < 25, q < 255; q++, j++)
    //   {

    for (i = 0; i < 40; i++)
    {
        // for(q=8; q<11; q++) {
        strip.setPixelColor(i, 255, 0, 25); //(i, 255, 0, 19);
        //   strip.setPixelColor(q, 1, 1, 1);
        //strip.show();

        //strip.setPixelColor(40, q, 0, q);

        strip.show();

        delay(5);
    }
    strip.show();
    // delay(5);
    // }

    // delay(300);
    //}

    // strip.show();
    //delay(300);
    Particle.publish("state", "continuas grrow light on");
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

/* bars todo: map all sensor data to pixels, update readings then update bars again( technechly is should happen automatecly in the switch*/
void bars()
{
    uint16_t i;
    //uint16_t q;
    ////////////////clear the matrix/////////////////////////////
    for (i = 0; i < 40; i++)
    {
        strip.setPixelColor(i, 0, 0, 0);
    }
    strip.show();
    Particle.publish("state", "grrow light off read");

    ///////////Wifi bar////////////////////////
    WiFiSignal sig = WiFi.RSSI();
    float strength = sig.getStrength();
    int signal = strength;
    int signal2 = map(signal, 0, 100, 0, 8);

    for (i = 0; i < signal2; i++)
    {
        // for(q=8; q<11; q++) {
        strip.setPixelColor(i, 0, 1, 0); // white
                                         //   strip.setPixelColor(q, 1, 1, 1);
                                         //  Particle.publish("sigquality", String(sig.getQuality()));
                                         //  delay(1000);
                                         //          Particle.publish("sigstrength", String(sig.getStrength()));
        delay(20);
        strip.show();
    } //}

    ///////////Moistuer bar///////////
    // mmoist = map(moist, 1921, 3344, 100, 0);
    int moistbar = map(mmoist, 0, 100, 8, 16);

    for (i = 8; i < moistbar; i++)
    {
        strip.setPixelColor(i, 0, 0, 1); // blue
        delay(20);
        strip.show();
    }

    //////////// light bar////////////////

    int lightbar = map(light, 0, 2024, 16, 24);
    if (lightbar >= 24)
    {
        lightbar = 24;
    }
    for (i = 16; i < lightbar; i++)
    {
        strip.setPixelColor(i, 1, 0, 1); // purple
        delay(20);
        strip.show();
    }

    //////////temp/////////////////
    int cc = static_cast<int>(c);
    int celes = map(cc, 0, 50, 24, 32);
    for (i = 24; i < celes; i++)
    {
        strip.setPixelColor(i, 1, 0, 0); //red
        delay(20);
        strip.show();
    }

    // Particle.publish("state", "grrow light off read");

    ///////////humid///////////////
    int hh = static_cast<int>(h);
    int humo = map(hh, 0, 100, 32, 40);
    for (i = 32; i < humo; i++)
    {
        strip.setPixelColor(i, 1, 1, 1); //red
        delay(20);
        strip.show();
    }

    Particle.publish("state", "light bars on");
}
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void moodone()
{
    Particle.publish("state", "mood light one");

    uint16_t i;
    uint16_t q;

    for (i = 0; i < 40; i++)
    {
        // for(q=8; q<11; q++) {
        strip.setPixelColor(i, 255, 50, 0); //warm
        //   strip.setPixelColor(q, 1, 1, 1);
        strip.show();
        delay(5);
    } //}

    // strip.show();
    Particle.publish("state", "mood light ON");
}

void moodtwo()
{
    Particle.publish("state", "mood light two");

    uint16_t i;
    uint16_t q;

    for (i = 0; i < 40; i++)
    {
        // for(q=8; q<11; q++) {
        strip.setPixelColor(i, 255, 150, 100); // white
        //   strip.setPixelColor(q, 1, 1, 1);
        strip.show();
        delay(5);
    } //}
    Particle.publish("state", "mood light ON");

    //strip.show();
    //Particle.publish("state", "grrow light on");
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void autog()
{
    if (reading == true && light < LowLight) /// light value should be moved to config
    {
        uint16_t i;
        uint16_t q;
        uint16_t j;

        for (i = 0; i < 40; i++)
        {
            // for(q=8; q<11; q++) {
            strip.setPixelColor(i, 255, 0, 25); //(i, 255, 0, 19);
                                                //   strip.setPixelColor(q, 1, 1, 1);
                                                //strip.show();

            //strip.setPixelColor(40, q, 0, q);

            //strip.show();

            //delay(10);

            strip.show();
            delay(5);
        }

        //strip.show();
        Particle.publish("state", "auto grow");
        Particle.publish("state", "grrow light ON");
    }
    else
    {
        //read();
        uint16_t i;

        for (i = 0; i < strip.numPixels(); i++)
        {
            strip.setPixelColor(i, 0, 0, 0);
        }
        Particle.publish("state", "grrow light OFFFFF");

        strip.show();
    }
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

void sleep()
{

    if (SleepMode)
    {

        //delay(1500);
        //loopCount++;
        if (reading = true)
        { // the kit will read 5 times before going to power saver sleep mode, you can edit the number to any number you like.
            Particle.publish("state", "Going to sleep for 1/2 minutes");
            //delay(10000);
            System.sleep(SLEEP_MODE_DEEP, SleepPeriod); // The kit will go into deep sleep mode to save power for x seconds,
                                                        // please edit to change the sleep time in IOP.H, example: 3600 seconds is one houre sleep time.
        }
        else
        {
            read();
        }
    }
}