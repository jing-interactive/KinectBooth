void drawStory(String bg, String fg, String textile, boolean isAlphaFg) {
  if (bg != null) {
    shader.set("bg", getImage(bg));
  }
  if (fg != null) {
    shader.set("fg", getImage(fg));
  }
  shader.set("realtime", kinectDevice.getRgbImage());
  if (textile != null) {
    shader.set("textile", getImage(textile));
  }
  shader.set("texFlags", fg != null, textile != null, isAlphaFg, bg != null);
  useShader();
  image(kinectDevice.getRgbImage());
  resetShader();
}

void drawStory(int idx, boolean playerOnly) {
  if (idx == 0) {
    shader.set("delta_hsv", _CFG_H0, _CFG_S0, 0);
    drawStory("2015/bg.jpg", null, null, false);
  } else if (idx == 1) {
    shader.set("delta_hsv", _CFG_H1, _CFG_S1, 0);
    drawStory("1600/bg.jpg", "1600/fg.png", "1600/textile.jpg", true);
  } else if (idx == 2) {
    shader.set("delta_hsv", _CFG_H2, _CFG_S2, 0);
    drawStory("1900/bg.jpg",  null, "1900/fg.jpg", false);
  } else {
    shader.set("delta_hsv", _CFG_H3, _CFG_S3, 0);
    drawStory("1980/bg.jpg", "1980/fg.jpg", null, false);
  }
}

class PlayState extends State {
  void enter() {
  }

  void quit() {
  }

  int sceneIdx = 0;

  void draw() {

    drawStory(1, CFG_Player_Only);

    if (keyPressed && key == 'b') {
      saveFrame("####_sketch.jpg");
      drawStory(0, false);
      saveFrame("####_2015.jpg");
      drawStory(1, false);
      saveFrame("####_1600.jpg");
      drawStory(2, false);
      saveFrame("####_1900.jpg");
      drawStory(3, false);
      saveFrame("####_1980.jpg");
    }
  }
}