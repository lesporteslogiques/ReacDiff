// Gweltaz Duval-Guennoc 27-04-2021

import controlP5.*;


ControlP5 cp5;
Group g;

PShader reacdiff;
PShader postproc;
PGraphics pg;

int ITERATIONS = 10;
int counter = 0;


void setup() {
  size(800, 600, P3D);
  //fullScreen(P3D);
  
  pg = createGraphics(width, height, P3D);
  pg.beginDraw();
  pg.background(0);
  pg.endDraw();
  
  postproc = loadShader("postproc.glsl");
  postproc.set("u_resolution", float(pg.width), float(pg.height));
  
  reacdiff = loadShader("reacdiff.glsl");
  reacdiff.set("u_resolution", float(pg.width), float(pg.height));
  reacdiff.set("scene", pg);
  
  cp5 = new ControlP5(this);
  
  int groupWidth = 170;
  int sliderHeight = 16;
  int sliderWidth = 130;
  g = cp5.addGroup("params")
    .setWidth(groupWidth)
    .setPosition(width-groupWidth-4, 14)
    .setBackgroundColor(color(0, 0, 128,50))
    ;
  
  int h = 0;
  cp5.addSlider("mode")
     .setPosition(0, h)
     .setSize(sliderWidth, sliderHeight)
     .setRange(0,2)
     .setValue(2)
     .setNumberOfTickMarks(3)
     .setSliderMode(Slider.FLEXIBLE)
     .setGroup(g)
     ;
  h += sliderHeight + 2;
  
  cp5.addSlider("points")
     .setPosition(0, h)
     .setSize(sliderWidth, sliderHeight)
     .setRange(2,8)
     .setValue(5)
     .setNumberOfTickMarks(7)
     .setSliderMode(Slider.FLEXIBLE)
     .setGroup(g)
     ;
  h += sliderHeight + 2;
  
  cp5.addSlider("size")
    .setPosition(0, h)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0.001f,0.1f)
    .setValue(0.02f)
    .setGroup(g)
    ;
  h += sliderHeight + 2;
  
  cp5.addSlider("feedA")
    .setPosition(0, h)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0.01f,0.1f)
    .setValue(0.0389f)
    .setGroup(g)
    ;
  h += sliderHeight + 2;
  
  cp5.addSlider("killB")
    .setPosition(0, h)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0.01f, 0.1f)
    .setValue(0.05904f)
    .setGroup(g)
    ;
  h += sliderHeight + 2;
  
  cp5.addSlider("diffA")
    .setPosition(0, h)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0.01f, 1.5f)
    .setValue(1.0f)
    .setGroup(g)
    ;
  h += sliderHeight + 2;
  
  cp5.addSlider("diffB")
    .setPosition(0, h)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0.01f, 1.8f)
    .setValue(0.5f)
    .setGroup(g)
    ;
  h += sliderHeight + 2;
  
  cp5.addSlider("smoothA")
    .setPosition(0, h)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0.0f, 1.0f)
    .setValue(0.4f)
    .setGroup(g)
    ;
  h += sliderHeight + 2;
  
  cp5.addSlider("smoothB")
    .setPosition(0, h)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0.0f, 1.0f)
    .setValue(0.5f)
    .setGroup(g)
    ;
  h += sliderHeight + 2;
  
  g.setBackgroundHeight(h);
}


void updateShader() {
  pg.beginDraw();
  pg.noStroke();
  pg.shader(reacdiff);
  pg.rect(0, 0, pg.width, pg.height);
  pg.endDraw();
}


void draw() {
  // Framerate optimisation
  if (++counter % 30 == 0) {
    surface.setTitle("Framerate " + String.valueOf(frameRate));
    println(frameRate, ITERATIONS);
    counter = 0;
    
    if (frameRate < 50)
      ITERATIONS--;
    else if (frameRate > 58)
      ITERATIONS++;
  }
  
  if (mousePressed && !insideGroup(g)) {
    float x = map(mouseX, 0, width, 0, 1);
    float y = map(mouseY, 0, height, 1, 0);
    reacdiff.set("mouse", x, y);
    reacdiff.set("spawn", true);
  } else {
    reacdiff.set("spawn", false);
  }
  
  reacdiff.set("u_feedA", cp5.getController("feedA").getValue());
  reacdiff.set("u_killB", cp5.getController("killB").getValue());
  reacdiff.set("u_diffA", cp5.getController("diffA").getValue());
  reacdiff.set("u_diffB", cp5.getController("diffB").getValue());
  reacdiff.set("u_mode", floor(cp5.getController("mode").getValue()));
  reacdiff.set("u_npoint", floor(cp5.getController("points").getValue()));
  reacdiff.set("u_size", cp5.getController("size").getValue());
  
  for (int i=0; i<ITERATIONS; i++)
    updateShader();
  
  shader(postproc);
  postproc.set("scene", pg);
  postproc.set("u_smooth", cp5.getController("smoothA").getValue(), cp5.getController("smoothB").getValue());
  noStroke();
  rect(0, 0, width, height);
  
  resetShader();
}


void keyPressed() {
  if (key == 'c') {
    pg.beginDraw();
    pg.clear();
    pg.endDraw();
  } else if (key == 's') {
    String filename = "reacdiff_";
    filename += String.valueOf(cp5.getController("feedA").getValue()) + '_';
    filename += String.valueOf(cp5.getController("killB").getValue()) + '_';
    filename += String.valueOf(cp5.getController("diffA").getValue()) + '_';
    filename += String.valueOf(cp5.getController("diffB").getValue()) + ".png";
    saveFrame(filename);
    println(filename + " saved");
  }
}


boolean insideGroup(Group group) {
  float x = group.getPosition()[0];
  float y = group.getPosition()[1];
  boolean isInside = false;
  if (group.isOpen()) {
    if (mouseX >= x
        && mouseX <= x + group.getWidth()
        && mouseY >= y
        && mouseY <= y + group.getBackgroundHeight())
      isInside = true;
  }
  isInside |= group.isMouseOver();
  
  return isInside;
}
