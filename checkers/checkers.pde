// **************************************************
// * checkers.pde
// * by cameyo 2013
// *
// * Gameboard checkers.
// *
// * code written for Processing 1.5.1 & 2.1
// * MIT license
// **************************************************
//
//  [N] key: start new game
//  [P] key: (un)promote picked piece
//  [F] key: change type of figures
//  [S] key: save window
//  [D] key: save diagram
//  [I] key: show/hide info

import java.util.Calendar;

// ********************
// VARIABLE DECLARATION
// ********************
String TITLE = "checkers";

// window info toggle
boolean showInfo;

// base coordinates of board
int baseX=68;
int baseY=68;

// number of pieces 
int numPieces=24;

// number of squares
int numSquares=32;

// array of pieces and their positions
int[][] pos = new int[numPieces][3];
// piece N
// pos[N][0] -> x coord
// pos[N][1] -> y coord
// pos[N][2] -> 0=white, 2=white DAMA
//              1=black, 3=black DAMA

// array of center of crosspoints
int[][] center = new int[64][2];

// array of figures (images)
PImage[] figure = new PImage[4];

// font for piece
PFont infoFont;
boolean FF=true;

// output filename
String filename;

// background color
color backC;

// board image
PImage boardIMG;

// background image
PImage backIMG;

// info image
PImage infoIMG;

// image of pieces
PImage wIMGa, bIMGa, wIMGb, bIMGb;
PImage wdIMGa, bdIMGa, wdIMGb, bdIMGb;

// picked piece
boolean pick=false;

// selected and captured piece index
int sel=-1;
int cap=-1;

// snap for select
int snap=24;

//selected piece values
int pieceIDX, figureIDX;

// counter
int i, j, k;

// ********************
// SETUP FUNCTION
// ********************
void setup()
{
  //******************************
  size(668, 668);
  //******************************
  // set window title
  frame.setTitle(TITLE);
  // set window icon image
  changeAppIcon();

  // smooth drawing
  smooth();
  // screen update
  frameRate(60);

  // set background color
  backC = color(60);
  background(backC);

  // set image mode
  imageMode(CENTER);  

  // load center coords of squares
  loadCenter();

  // load board images
  boardIMG = loadImage("board.jpg");
  backIMG = loadImage("background.jpg");
  infoIMG = loadImage("infoButton.jpg");  

  //load piece images
  wIMGa = loadImage("whiteA.png");
  wdIMGa = loadImage("whiteAd.png");  
  bIMGa = loadImage("blackA.png");  
  bdIMGa = loadImage("blackAd.png");    
  
  wIMGb = loadImage("whiteB.png");
  wdIMGb = loadImage("whiteBd.png");  
  bIMGb = loadImage("blackB.png");  
  bdIMGb = loadImage("blackBd.png");    

  // load and set font
//  infoFont = loadFont("BitstreamVeraSans-Roman-12.vlw");
  infoFont = loadFont("CourierNewPSMT-12.vlw");  

  textAlign(CENTER);

  // initialize figures
  // WHITE figure
  figure[0] = wIMGa;
  figure[2] = wdIMGa;  
  // BLACK figure    
  figure[1] = bIMGa;
  figure[3] = bdIMGa;  

  // draw board
  drawBoard();

  // load nine start position
  startPosition();
}


// ********************
// DRAW FUNCTION
// ********************
void draw()
{
  // set background color
  background(backC);

  // set background image
  image(backIMG, width/2, height/2);

  // draw board
  drawBoard();

  // draw info button
  // drawInfoButton();

  // ********************
  // draw all pieces
  // ********************

  for (i=0;i<numPieces;i++)
  {
    image(figure[pos[i][2]], pos[i][0], pos[i][1]);
    //text(figure[pos[i][2]],pos[i][0],pos[i][1]);
    //println(i + " - " + pos[i][0] + " - " + pos[i][1]);
  }

  // if picked piece then draw it
  if (pick)
  {
    image(figure[pos[pieceIDX][2]], mouseX, mouseY);
    //text(figure[pos[pieceIDX][2]],mouseX,mouseY);
  }

  //  DEBUGGING CODE
//    textFont(infoFont);
//    for (i=0;i<32;i++)
//    {
//      fill(0);
//      ellipse(center[i][0],center[i][1],3,3);
//      text(i+"-"+center[i][0]+"-"+center[i][1],center[i][0],center[i][1]);
//      println(i+"-"+center[i][0]+"-"+center[i][1]);
//    }

  // draw info window
  if (showInfo)
  {
    fill(0, 210);
    rectMode(CENTER);
    textAlign(CENTER);
    noStroke();
    rect(width/2, height/2, 300, 220);
    fill(240);
    textFont(infoFont);
    text("CHECKERS by cameyo", width/2, height/2-80-10);
    text("To play Checkers.", width/2, height/2-58-10);        
    textAlign(LEFT);
    text("Click to select a piece and...", width/2-110, height/2-36-10);
    text("...click to release (autocenter).", width/2-110, height/2-22-10);
    text("[N] key: start new game", width/2-110, height/2+2-10);
    text("[P] key: (un)promote picked piece", width/2-110, height/2+22-10);    
    text("[F] key: change type of figures", width/2-110, height/2+42-10);
    text("[S] key: save window", width/2-110, height/2+62-10);
    text("[D] key: save diagram", width/2-110, height/2+82-10);
    text("[I] key: show/hide info", width/2-110, height/2+102-10);
    text("________________________________________", width/2-141, height/2+112-10);
  }
}


// ***************************
// KEYBOARD INTERACTION
// ***************************
void keyPressed()
{
  // start new game
  if (key=='n' || key=='N')
  {
    pick=false;
    startPosition();
  }

  // set current picked piece to DAMA (toggle)
  if (key=='p' || key=='P')
  {
    if (pick)
    {
      if (pieceIDX<12) //white piece to DAMA
      {
        if (pos[pieceIDX][2]==2)
        {
         pos[pieceIDX][2]=0;
         figureIDX=0;
        }
        else 
        {
         pos[pieceIDX][2]=2;
         figureIDX=2;
        }        
      }  
      else // black piece to DAMA
      {
        if (pos[pieceIDX][2]==3)
        {
          pos[pieceIDX][2]=1;
          figureIDX=1;
        }  
        else
        {
          pos[pieceIDX][2]=3;
          figureIDX=3;
        }
      }      
    }
  }  

  // change type of figures
  if (key=='f' || key=='F')
  {
    FF = !(FF);
    if (FF) 
    { 
      figure[0] = wIMGa;
      figure[1] = bIMGa;  
      figure[2] = wdIMGa;
      figure[3] = bdIMGa;      
    }
    else 
    { 
      figure[0] = wIMGb;
      figure[1] = bIMGb;
      figure[2] = wdIMGb;
      figure[3] = bdIMGb;      
    }
  }

  // show info window
  if (key=='i' || key=='I')
  {
    showInfo = !(showInfo);
  }

  // save image window
  if (key=='s' || key=='S')
  {
    saveFrame("s" + timestamp() + ".png");
  }

  // save board image (only)
  if (key=='d' || key=='D')
  {
    PImage outIMG;
    outIMG = get(baseX, baseY, 532, 532);
    outIMG.save("d" + timestamp() + ".png");
  }
  
  // intercept ESC key
  if (keyCode==ESC)
  {
    key=0;
    //println("ESC");
  }  
}


// ***************************
// MOUSE INTERACTION
// ***************************

// ***************************
// mousePressed
// ***************************
void mousePressed()
{
  //  println("mouse: " + mouseX + " - " + mouseY);
  sel=-1;
  cap=-1;

  if (pick) // Second pick -> place piece
  {
//    pos[pieceIDX][0] = mouseX;
//    pos[pieceIDX][1] = mouseY;
//    pos[pieceIDX][2] = figureIDX;
    centerPiece();
    pick=false;
    // check if captured piece
    //checkCapture();
  }
  else
  {
    //check if clicked on a piece
    for (i=0;i<numPieces;i++)
    {
      if ((mouseX > pos[i][0]-snap) && (mouseX < pos[i][0]+snap) && (mouseY > pos[i][1]-snap) && (mouseY < pos[i][1]+snap))
      {
        // piece selected
        //println("selected");
        sel=1;
        pieceIDX = i;
        figureIDX = pos[pieceIDX][2];
        // reset X and Y coord (move outside window)
        pos[pieceIDX][0] = -100;
        pos[pieceIDX][1] = -100;
        pick = true;
        break;
      }
    }
  }

  if ((sel==-1) && (cap==-1)) { 
    pick=false;
  }
  // println(pick);

  // check if press info button
  if ((mouseX > width-18) && (mouseX < width) && (mouseY > 0) && (mouseY < 18))
  {
    showInfo = !(showInfo);
  }
}

// ***************************
// mouseMoved
// ***************************
void mouseMoved()
{
  //set cursor
  // check if piece is selected
  if (pick) 
  { 
    cursor(CROSS);
  }
  else
  { 
    if (!pick) 
    { 
      cursor(ARROW);
      // check if mouse over pieces
      for (i=0;i<numPieces;i++)
      {
        if ((mouseX > pos[i][0]-snap) && (mouseX < pos[i][0]+snap) && (mouseY > pos[i][1]-snap) && (mouseY < pos[i][1]+snap))
        {
          cursor(HAND);
          break;
        }
      }
    }    
    // check mouse over info button
    if ((mouseX > width-18) && (mouseX < width) && (mouseY > 0) && (mouseY < 18))
    {
      cursor(HAND);
    }
  } 
}


// ************************
// drawInfoButton FUNCTION
// ************************
void drawInfoButton()
{
  image(infoIMG,659,9);
}


// **********************
// drawBoard FUNCTION
// **********************
void drawBoard()
{
  image(boardIMG, width/2, height/2);
}

// **********************
// centerPiece FUNCTION
// **********************
void centerPiece()
{
  float dd;
  float minDist = 9999.0;

  // place piece within chessboard
  if ((mouseX > 68) && (mouseX < 600) && (mouseY > 68) && (mouseY < 600))
  {
    // search the nearest square (crosspoint)
    for (i=0;i<numSquares;i++)
    {
      dd =dist(mouseX, mouseY, center[i][0], center[i][1]);
      if (dd < minDist)
      {
        boolean libero=true;
        for(k=0;k<numPieces;k++)
        { 
          if ((center[i][0]==pos[k][0]) && (center[i][1]==pos[k][1]))
          {
            libero=false;
          }
        }
        if (libero==true)  
        { 
          minDist=dd;
          pos[pieceIDX][0] = center[i][0];
          pos[pieceIDX][1] = center[i][1];
          pos[pieceIDX][2] = figureIDX;
        }
      }
    }
  }
  // place piece outside chessboard
  else
  {
    pos[pieceIDX][0] = mouseX;
    pos[pieceIDX][1] = mouseY;
    pos[pieceIDX][2] = figureIDX;
  }
}


// **********************
// checkCapture FUNCTION
// **********************
void checkCapture()
{
  cap=-1;
  //check if clicked on a piece (capture it !!)
  for (i=0;i<numPieces;i++)
  {
    if (((mouseX > pos[i][0]-snap) && (mouseX < pos[i][0]+snap) && (mouseY > pos[i][1]-snap) && (mouseY < pos[i][1]+snap)) &&
       (i!=pieceIDX)) // not the piece selected !!
    {
      // piece captured
      //println("captured");
      cap=1;
      pieceIDX = i;
      figureIDX = pos[pieceIDX][2];
      // reset X and Y coord (move outside window)
      pos[pieceIDX][0] = -100;
      pos[pieceIDX][1] = -100;
      pick = true;
      break;
    }
  }
}


// **********************
// changeAppIcon FUNCTION
// **********************
void changeAppIcon()
{
  // create icon for application
  PGraphics icon = createGraphics(16, 16, JAVA2D);
  // draw icon
  icon.beginDraw();
  icon.noStroke();
  icon.fill(255);
  icon.rect(3, 3, 10, 10);
  icon.fill(0);
  icon.rect(3,3,5,5);
  icon.rect(8, 8, 5, 5);
  icon.endDraw();
  // set icon
  frame.setIconImage(icon.image);
}


// **********************
// timestamp FUNCTION
// **********************
String timestamp()
{
  Calendar now = Calendar.getInstance();
  return String.format("20%1$ty-%1$tm-%1$td_%1$tH.%1$tM.%1$tS", now);
}

