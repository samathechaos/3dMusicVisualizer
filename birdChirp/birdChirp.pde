import processing.opengl.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;          
AudioPlayer jingle;   
FFT fft;              //FFT (Ferrier Form Transformation) Object that hold band data
int numS = 80;        //Const that dictates how many bands will get read
System s;             //An arraylist object that holds all of the WaveForm's and parses through them
float zoom = 100;     //A variable that controls the starting zoom

//Setup
void setup() {
  fullScreen(OPENGL);
  minim = new Minim(this);                        //instantiate the Minim master object  
  jingle = minim.loadFile("birdChirp.mp3", 512); //load song file
  jingle.loop();                                  //loop song file
  fft = new FFT(jingle.bufferSize(), jingle.sampleRate()); // create an FFT object that has a time-domain buffer the same size as jingle's sample buffer
                                                           // note that this needs to be a power of two 
  s = new System();                              //make a new system
}

void draw()
{
  WaveForm w = new WaveForm(numS);              //make a new WaveForm object every time you draw. This object is then passed to the system which draws it and all of the existing waveforms
  background(0);  
  pointLight(51, 102, 255, 65, 60, 100);        //Some 3D lightning for neat effect
  pointLight(200, 40, 60, -65, -60, -150);  
  ambientLight(70, 70, 10);                     // Raise overall light in scene 
  
  
  fft.forward(jingle.mix);                      //get the data
  for(int i = 0; i < numS; i++)  {
    w.importBand(fft.getBand(i), i);            //pass the data to the WaveForm
  }
  s.addWave(w);                                 //Add the WaveForm to the System
  //noStroke();                                   
  s.render();
}


//WaveForm class
class WaveForm {
  float[] bandMap; //holds all of the getBand() numbers from FFT
  int sz;          //size of the array
  //Constructor
  WaveForm(int _sz) {
    sz = _sz;
    bandMap = new float[sz];
  }
  //place value to a position in the array
  void importBand(float i, int place) {
    bandMap[place] = i;
  }
}


//System Class
class System {
  ArrayList waves;
  float xyScale = 20.0f; //Contracts or expands flowing shape

  System() {   
    waves = new ArrayList();
  }
  
  //Render waves
  void render() {
    translate(-xyScale * 8, 0, -100);
    //Basically, this takes two waves (going through the whole array of course and creates and bunch of
    //rectangles between them to synthesize a flowing shape. It really is a lot scarier than it looks.
    for (int y = 1; y < waves.size(); y++) {
      WaveForm w1 = (WaveForm) waves.get(y-1); //The two waves
      WaveForm w2 = (WaveForm) waves.get(y);
      beginShape(QUADS);                       //Making sure th rendered creates squares (i think this code could be optimized to use TRIANGLE_STRIP)
      for(int x=1; x < w1.sz; x++) {
        fill(200, 255-w1.bandMap[x]  * 8, 255);
        vertex(x*xyScale,y*xyScale, w1.bandMap[x-1]);
        vertex(x*xyScale,(y+1)*xyScale,w2.bandMap[x-1]);
        vertex((x+1)*xyScale,(y+1)*xyScale,w2.bandMap[x]);
        vertex((x+1)*xyScale,y*xyScale,w1.bandMap[x]);
      }
      endShape();
    }
    //popMatrix();
    
  }

  //adds a WaveForm object to the front of the list
  void addWave(WaveForm w) {
    waves.add(0,w);
  }
}
//Sama Manchanda
//code attributes to processing user: theinhibitor