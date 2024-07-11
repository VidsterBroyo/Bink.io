/******************************************************************************
 * Vidu Widyalankara                            Vidu_Widyalankara_Bink_io.pde
 *
 * COURSE: ICS3U1
 * ASSIGNMENT: SUMMATIVE, BINK.IO
 *
 * DESCRIPTION :
 *       A recreation of the game Bonk.io.
 *
 * VERSION DATE: 1/24/2023
 ******************************************************************************/
import processing.sound.*;

// button class
class Button {
  float x, y, w, h;
  color buttonColor;
  String buttonText;

  Button (float _x, float _y, float _w, float _h, color _c, String _bt) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    buttonColor = _c;
    buttonText = _bt;
  }
  
  // draw button
  void drawB() {
    fill(buttonColor);
    rect(x, y, w, h);

    fill(#000000);
    textSize(40);
    textAlign(CENTER, CENTER);
    text(buttonText, x+(w/2), y+(h/2)-5); // center text
  }
  
  // if mouse is over button
  boolean mouseOver() {
    return (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h);
  }
}


// platform class
class Platform {
  float x, y, w, h;

  Platform (float _x, float _y, float _w, float _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }
  
  // draw platform
  void drawPlatform() {
    stroke(#000000);
    fill(#333333);
    rect(x, y, w, h);
  }
}


// player class
class Player {
  PVector Pos, Vel, Acc;
  boolean touchingSurface;
  boolean jump;
  int pushFactor;
  int score;
  color playerColor;

  Player (PVector p, PVector v, PVector a, boolean ts, color c) {
    Pos = p;
    Vel = v;
    Acc = a;
    touchingSurface = ts;
    jump = false;
    pushFactor = 1;
    score = 0;
    playerColor = c;
  }

  // draw player
  void drawPlayer() {
    stroke((pushFactor-1)*#FFFFFF);
    fill(playerColor);
    rect(Pos.x, Pos.y, 40, 40);
  }
  
  // move player
  void move() {
    if (abs(Vel.x+Acc.x) <= 10) {
      Vel = Vel.add(Acc);
    }

    if (jump && touchingSurface) {
      Vel.y = -20;
    }

    Vel = Vel.add(Gravity);
    Pos = Pos.add(Vel);

    println("\nPosition: "+Pos);
    println("Acceleration: "+Acc);
    println("Gravity: "+Gravity);
    println("Velocity: "+Vel);

    touchingSurface = false;
    for (int i=0; i<platforms.length; i++) {
      if (Pos.y > (platforms[i].y)-40 && Pos.y < (platforms[i].y) && Pos.x > (platforms[i].x)-40 && Pos.x < (platforms[i].x)+platforms[i].w) {
        Vel.y = 0;
        Pos.y = platforms[i].y-40;
        touchingSurface = true;
      }
    }

    if (Pos.x < 0) {
      Vel.x = 0;
      Pos.x = 0;
    } else if (Pos.x > width-40) {
      Vel.x = 0;
      Pos.x = width-40;
    }
  }
  
  // check if player died
  boolean hitFloor() {
    return Pos.y > height;
  }
  
  // check for player collision
  void checkCollision(Player playerChecking) {
    if (Pos.x+40+Vel.x >= playerChecking.Pos.x && Pos.x <= playerChecking.Pos.x+40+Vel.x && Pos.y+40 >= playerChecking.Pos.y && Pos.y <= playerChecking.Pos.y+40) {
      collidingVelocity = Vel.x;
      Vel.x = playerChecking.Vel.x;
      playerChecking.Vel.x = collidingVelocity*pushFactor;
    }

    if (Pos.x+40 >= playerChecking.Pos.x && Pos.x <= playerChecking.Pos.x+40 && Pos.y+40+Vel.y >= playerChecking.Pos.y && Pos.y+Vel.y <= playerChecking.Pos.y+40) {
      collidingVelocity = Vel.y;
      Vel.y = playerChecking.Vel.y;
      playerChecking.Vel.y = collidingVelocity*pushFactor;
    }
  }
}

// game variables
int gameState = 0;
int startTime;

// asset variables
SoundFile music;
SoundFile hover;
SoundFile fall;
PFont font;
int[][] squares = new int[30][5]; // game background squares

// physics variables
PVector Gravity = new PVector(0, 0.81);
float collidingVelocity = 0;

// player variables & objects
String winPlayer = "1";
Player p2 = new Player(new PVector(900, 200), new PVector(0, 0), new PVector(0, 0), false, #0000FF);
Player p1 = new Player(new PVector(400, 200), new PVector(0, 0), new PVector(0, 0), false, #FF0000);
Platform[] platforms = new Platform[7];

// button objects
Button playButton = new Button(500, 500, 200, 75, #00FF00, "PLAY");
Button instructionsButton = new Button(400, 600, 400, 75, #00FF00, "INSTRUCTIONS");
Button backButton = new Button(500, 600, 200, 75, #00FF00, "BACK");


void setup() {
  // setup screen
  size(1200, 800);
  background(#000000);

  // load assets
  font = createFont("pixelFont.ttf", 128);
  textFont(font);
  hover = new SoundFile(this, "hover.wav");
  fall = new SoundFile(this, "fall.wav");
  music = new SoundFile(this, "music.mp3");
  music.loop();

  createSquares(); // create background
  generatePlatforms(); // generate random platforms
}


void draw() {
  background(#000000);

  // start screen
  if (gameState == 0) {
    drawStartBackground();

    // title
    fill(#FFFFFF);
    textAlign(CENTER);
    textSize(80);
    text("BINK.IO", 600, 200);

    // buttons
    playButton.drawB();
    instructionsButton.drawB();

    // instructions
  } else if (gameState == 1) {
    drawStartBackground();

    // title
    fill(#FFFFFF);
    textAlign(CENTER);
    textSize(60);
    text("INSTRUCTIONS", 600, 150);

    // instructions
    textSize(35);
    text("Objective: Push the other player off", 600, 250);
    stroke(#FFFFFF);
    line(600, 300, 600, 750);

    fill(#0000FF);
    text("Player 1", 300, 325);

    fill(#FF0000);
    text("Player 2", 900, 325);

    textSize(30);
    fill(#AAAAAA);
    text("Use the arrow keys\nto move\n\nPress [CTRL] to push", 900, 410);
    text("Use WASD to move\n\n\nPress [X] to push", 300, 410);

    // button
    backButton.drawB();

    // game or win screen
  } else if (gameState == 2 || gameState == 3) {

    // draw platforms
    for (int i=0; i<platforms.length; i++) {
      platforms[i].drawPlatform();
    }

    // draw players
    p1.drawPlayer();
    p2.drawPlayer();

    // move players and check if they colllide
    p1.move();
    p2.move();
    p1.checkCollision(p2);
    p2.checkCollision(p1);

    // check for win
    if (gameState == 2) {
      // add to score, start timer for score display
      if (p1.hitFloor()) {
        p2.score++;
        winPlayer = "2";
        gameState = 3;
        displayScore();
        startTime = millis();
        fall.play();
      } else if (p2.hitFloor()) {
        p1.score++;
        gameState = 3;
        winPlayer = "1";
        displayScore();
        startTime = millis();
        fall.play();
      }
    }

    // score display
    if (gameState == 3) {
      if (millis() - startTime > 2000) {
        // if win, go to start screen
        if (p1.score > 4 || p2.score > 4) {
          gameState = 0;
        } else {
          gameState = 2;

          // reset player positions
          p1.Pos = new PVector(900, 200);
          p2.Pos = new PVector(400, 200);
          p1.Vel = new PVector(0, 0);
          p2.Vel = new PVector(0, 0);
        }
      } else {
        displayScore();
      }
    }
  }
}


void generatePlatforms() {
  // make 2 platforms that ensure players don't just fall on spawn
  platforms[0] = new Platform(350, int(random(300, height)), int(random(90, 400)), 20);
  platforms[1] = new Platform(700, int(random(300, height)), int(random(90, 400)), 20);

  // for loop to randomly generate platforms
  for (int i=2; i<7; i++) {
    platforms[i] = new Platform(int(random(width)), int(random(200, height)), int(random(90, 400)), 20);
  }
}


void createSquares() {
  // create 30 random squares for the start screen
  for (int i=0; i<30; i++) {
    squares[i][0] = int(random(0, 1150));
    squares[i][1] = int(random(0, 750));
    squares[i][2] = int(random(-20, 20));
    squares[i][3] = int(random(-20, 20));
    squares[i][4] = color((i%2)*255, 0, 255-(i%2)*255);
  }
}


void drawStartBackground() {
  stroke(#000000);
  for (int i=0; i<30; i++) {
    // draw squares
    fill(squares[i][4]);
    rect(squares[i][0], squares[i][1], 40, 40);

    // move squares
    squares[i][0] += squares[i][2];
    squares[i][1] += squares[i][3];

    // bounce squares off sides of screen
    if (squares[i][0]+40 > width) {
      squares[i][0]=1160;
      squares[i][2] = -squares[i][2];
    } else if (squares[i][0] < 0) {
      squares[i][0]=0;
      squares[i][2] = -squares[i][2];
    }

    if (squares[i][1]+40 > height) {
      squares[i][1]=760;
      squares[i][3] = -squares[i][3];
    } else if (squares[i][1] < 0) {
      squares[i][1]=0;
      squares[i][3] = -squares[i][3];
    }

    // check if squares hit other squares
    for (int j=0; j<30; j++) {
      if (squares[i][0]+40 >= squares[j][0] && squares[i][0] <= squares[j][0]+40 && squares[i][1]+40+(squares[i][3]) >= squares[j][1] && squares[i][1]+(squares[i][3]) <= squares[j][1]+40) {
        int holdV = squares[i][3];
        squares[i][3] = squares[j][3];
        squares[j][3] = holdV;

        squares[j][4] = squares[i][4];
      }

      if (squares[i][0]+40+(squares[i][2]) >= squares[j][0] && squares[i][0]+(squares[i][2]) <= squares[j][0]+40 && squares[i][1]+40 >= squares[j][1] && squares[i][1] <= squares[j][1]+40) {
        int holdV = squares[i][2];
        squares[i][2] = squares[j][2];
        squares[j][2] = holdV;

        squares[j][4] = squares[i][4];
      }
    }
  }
}


void displayScore() {
  fill(#222222);
  rect(400, 300, 400, 200);

  fill(#FFFFFF);
  textAlign(CENTER);
  text("P1: "+p1.score, 600, 430);
  text("P2: "+p2.score, 600, 480);

  // check if text should read "WINS" or "Scores"
  if (p1.score > 4 || p2.score > 4) {
    text("Player "+winPlayer+" WINS!", 600, 370);
  } else {
    text("Player "+winPlayer+" Scores!", 600, 370);
  }
}


// reset players positions and velocities and platforms
void resetPlayers() {
  p1.Vel = new PVector(0, 0);
  p1.Pos = new PVector(900, 200);
  p1.score = 0;

  p2.Vel = new PVector(0, 0);
  p2.Pos = new PVector(400, 200);
  p2.score = 0;

  generatePlatforms();
}


void mouseMoved() {
  if (gameState == 0) {
    // check for hover over play button, change color and play sound
    if (playButton.mouseOver() && playButton.buttonColor == #00FF00) {
      playButton.buttonColor = #FFFFFF;
      hover.play();
    } else if (!playButton.mouseOver()) {
      playButton.buttonColor = #00FF00;
    }
    // check for hover over play button, change color and play sound
    if (instructionsButton.mouseOver() && instructionsButton.buttonColor == #00FF00) {
      instructionsButton.buttonColor = #FFFFFF;
      hover.play();
    } else if (!instructionsButton.mouseOver()) {
      instructionsButton.buttonColor = #00FF00;
    }
  } else if (gameState == 1) {
    // check for hover over play button, change color and play sound
    if (backButton.mouseOver() && backButton.buttonColor == #00FF00) {
      backButton.buttonColor = #FFFFFF;
      hover.play();
    } else if (!backButton.mouseOver()) {
      backButton.buttonColor = #00FF00;
    }
  }
}


void mousePressed() {
  if (gameState == 0) {
    // check if play button is clicked
    if (playButton.mouseOver()) {
      resetPlayers();
      gameState = 2;

      // check if instructions button is clicked
    } else if (instructionsButton.mouseOver()) {
      gameState = 1;
    }
  } else if (gameState == 1) {
    // check if back button is clicked
    if (backButton.mouseOver()) {
      gameState = 0;
    }
  }
}


void keyPressed() {
  // listening for right, left, up, CTRL keys for player control
  if (keyCode == 38) {
    if (p1.touchingSurface) {
      p1.jump = true;
    } else {
      p1.Acc.y= -0.4;
    }
  } else if (keyCode == 17) {
    p1.pushFactor = 2;
  } else if (keyCode == 39) {
    p1.Acc.x = 0.5;
  } else if (keyCode == 37) {
    p1.Acc.x = -0.5;
  }


  // listening for W, A, D, X keys for player control
  else if (keyCode == 87) {
    if (p2.touchingSurface) {
      p2.jump = true;
    } else {
      p2.Acc.y= -0.4;
    }
  } else if (keyCode == 88) {
    p2.pushFactor = 2;
  } else if (keyCode == 68) {
    p2.Acc.x = 0.5;
  } else if (keyCode == 65) {
    p2.Acc.x = -0.5;
  }
}


void keyReleased() {
  // listening for release of keys for player control
  if (keyCode == 39 || keyCode == 37) {
    p1.Acc.x = 0;
  } else if (keyCode == 68 || keyCode == 65) {
    p2.Acc.x = 0;
  } else if (keyCode == 38) {
    p1.jump = false;
    p1.Acc.y= 0;
  } else if (keyCode == 87) {
    p2.jump = false;
    p2.Acc.y= 0;
  } else if (keyCode == 17) {
    p1.pushFactor = 1;
  } else if (keyCode == 88) {
    p2.pushFactor = 1;
  }
}
