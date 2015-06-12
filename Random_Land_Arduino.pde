import cc.arduino.*;
import processing.serial.*;
import processing.opengl.*;


Arduino arduino;

float bright;
float fCol;
float xoff;
float yoff;

int transY, transX;

float zeroingX, zeroingY;

float seLev = -.5;

color[] store;
float[] vals;

int x = 0;

float hMult = 15.0;

color grass;
color rock;
color sea;
color snow;
color sand;

int boxSize = 5;

float zoom = .01;


PShape[] shapes;

PShape test;


float rotX, rotY, rotZ;

void setup() {
  size(1400, 700, OPENGL);
  colorMode(HSB, 360, 100, 100);
  grass = color(81, 91, 75);
  rock = color(99, 17, 64);
  sea = color(220, 99, 93);
  snow = color(360, 0, 100);
  sand = color(57, 58, 88);

  shapes = new PShape[width*height];

  test = createShape();
  test.beginShape();
  test.fill(0);
  test.vertex(0, 0);
  test.vertex(0, 50);
  test.vertex(50, 50);
  test.vertex(50, 0);
  test.endShape(CLOSE);

  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);

  store = new color[width*height];
  vals = new float[width*height];

  newStore(seLev, 0, 0);
}

void newStore(float a, float b, float c) {

  xoff = b;

  for (int x = 0; x < width; x++) {

    yoff = c;

    for (int y = 0; y < height; y++) {
      vals[x+y*width] = map(noise(xoff, yoff), 0, 1, -4, 10); 

      if (vals[x+y*width] < a) {
        store[x+y*width] = sea;
      }//sea

        else if (vals[x+y*width] < .2+a && vals[x+y*width] >= a) {
        store[x+y*width] = sand;
      }//grass

      else if (vals[x+y*width] < 2.5+a && vals[x+y*width] >= .2+a) {
        store[x+y*width] = grass;
      }//grass

        else if (vals[x+y*width] >= 2.5+a && vals[x+y*width] < 5.5+a) {
        store[x+y*width] = rock;
      }//mountain

      else if (vals[x+y*width] >= 5.5+a) {
        store[x+y*width] = snow;
      }//snow


        yoff += zoom;
    }
    xoff += zoom;
  }
}

void newTreeStore() {
}


void draw() {
  translate(transX, transY);
  rotateX(radians(rotX));
  rotateY(radians(rotY));
  rotateZ(radians(rotZ));

  fill(160);

  pushMatrix();
  translate(2000, 0, 0);
  rotateY(radians(90));
  rect(-10000, -10000, 40000, 40000);
  popMatrix();

  pushMatrix();
  translate(-2000, 0, 0);
  rotateY(radians(90));
  rect(-10000, -10000, 40000, 40000);
  popMatrix();

  pushMatrix();
  translate(0, 0, 2000);
  rect(-10000, -10000, 40000, 40000);
  popMatrix();

  pushMatrix();
  translate(0, 0, -2000);
  rect(-10000, -10000, 40000, 40000);
  popMatrix();

  pushMatrix();
  translate(0, 2000, 0);
  rotateX(radians(90));
  rect(-10000, -10000, 40000, 40000);
  popMatrix();

  pushMatrix();
  translate(0, -2000, 0);
  rotateX(radians(90));
  rect(-10000, -10000, 40000, 40000);
  popMatrix();


hMult = (15.0*.01)/zoom;


  for (int x = 0; x < width-boxSize; x+=boxSize) {

    //if (x < width-boxSize)
    //  x+=5;

    for (int y = 0; y < height-boxSize; y+=boxSize) {


      beginShape();
      fill(store[(x/boxSize)+(y/boxSize)*width]);
      vertex(x, height*.75-(vals[(x/boxSize)+(y/boxSize)*width]*hMult), y-height/2);
      vertex(x+boxSize, height*.75-(vals[((x/boxSize)+1)+(y/boxSize)*width]*hMult), y-height/2);
      vertex(x+boxSize, height*.75-(vals[((x/boxSize)+1)+((y/boxSize)+1)*width]*hMult), y+boxSize-height/2);
      vertex(x, height*.75-(vals[(x/boxSize)+((y/boxSize)+1)*width]*hMult), y+boxSize-height/2);
      endShape();

      //pushMatrix();
      //translate(0, 0, -y);
      //shape(shapes[(x/boxSize)+(y/boxSize)*width]);
      //popMatrix();
    }
  }

  fill(220, 99, 93, 100);
  pushMatrix();
  translate(0, height*.75-seLev*hMult, height*2.5);
  rotateX(radians(-90));
  rect(0, width, width, height);
  popMatrix();


  //shape(test, 100, 100);

  seLev = map(arduino.analogRead(3), 0, 1024, -3.0, 8.0);

  newStore(seLev, zeroingX, zeroingY);
}

void keyPressed() {
  if (key == 'r') {
    zeroingX = millis();
    zeroingY = zeroingX;
    newStore(seLev, zeroingX, zeroingY);
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    rotY+=(mouseX-pmouseX);
    rotX-=(mouseY-pmouseY);
  } 
  if (mouseButton == RIGHT) {
    transX+=(mouseX-pmouseX);
    transY+=(mouseY-pmouseY);
  }
}


void mouseWheel(MouseEvent event) {
  float a = event.getCount();
  if (a >= 0) {
    if (zoom > .0001)
      zoom -= .001;
  } else {
    if (zoom <= .1)
      zoom += .001;
  }
}

