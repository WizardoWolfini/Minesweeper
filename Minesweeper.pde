

import de.bezier.guido.*;
//Declare and initialize NUM_ROWS and NUM_COLS = 20
private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> bombs; //ArrayList of just the minesweeper buttons that are mined
private int NUM_COLS;
private int NUM_ROWS;
private int maxBombs;
private boolean firstClick;
private boolean isLost;
void setup ()
{
  isLost = false;
  firstClick = true;
  NUM_COLS = 9*4;
  NUM_ROWS = 6*4;
  bombs = new ArrayList<MSButton>();
  buttons = new MSButton[NUM_ROWS][NUM_COLS];
  maxBombs = 99;
  size(1080, 800);
  textAlign(CENTER, CENTER);

  // make the manager
  Interactive.make( this );
  for (int i = 0; i < NUM_ROWS; i++) {
    for (int j = 0; j < NUM_COLS; j++) {
      MSButton nButton = new MSButton(i, j);
      buttons[i][j] = nButton;
    }
  }
}
public void draw ()
{
  background( 255 );
  fill(100);
  textSize(75);
  int bombsLeft = maxBombs - countMarked();
  if (!isWon() || !isLost) {
    text("Bombs Remaining: " + bombsLeft, 500, 750);
  }
  if (isWon()) {
    background( 255 );
    displayWinningMessage();
  }
  textSize(15);
}
public int countMarked() {
  int tempintM = 0;
  for (MSButton[] buttona : buttons) {
    for (MSButton button : buttona) {
      if (button.isMarked()) {
        tempintM++;
      }
    }
  }
  return tempintM;
}
public boolean isWon()
{  
  int tempintC = 0;
  for (MSButton[] buttona : buttons) {
    for (MSButton button : buttona) {
      if (button.isClicked()) {
        tempintC++;
      }
    }
  }
  int tempinta = NUM_COLS * NUM_ROWS - tempintC - maxBombs;
  if (tempinta == 0) {
    return true;
  }
  //your code here
  return false;
}
public void displayLosingMessage()
{
  //your code here
}
public void displayWinningMessage()
{
  noLoop();
  text("You Win!", 500, 750);
  //your code here
}

public class MSButton
{
  private int r, c;
  private float x, y, width, height;
  private boolean clicked, marked;
  private String label;
  private boolean ifFC = false;
  private boolean alive = true;
  public MSButton ( int rr, int cc )
  {
    width = 1080/NUM_COLS;
    height = 720/NUM_ROWS;
    r = rr;
    c = cc; 
    x = c*width;
    y = r*height;
    label = "";
    marked = clicked = false;
    Interactive.add( this ); // register it with the manager
  }
  public void changeClickedF() {
    clicked = false;
    marked = false;
    setLabel("");
  }
  public void kill() {
    alive = false;
  }
  public boolean isMarked()
  {
    return marked;
  }
  public boolean firstClicked() {
    return ifFC;
  }
  public boolean isClicked()
  {
    return clicked;
  }
  public int getNum() {
    return r*NUM_COLS + c;
  }
  // called by manager

  public void mousePressed () 
  {
    if (mouseButton == RIGHT && !firstClick) {
      if (clicked == false) {
        marked = !marked;
      } else if (marked == false) {
        mouseButton = LEFT;
        if (countBombs(r, c) - countMarked(r, c) == 0) {
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              if (!(i == 0 && j == 0)) {
                if (isValid(r+i, c+j) && !buttons[r+i][j+c].isClicked()) {
                  buttons[r+i][c+j].mousePressed();
                }
              }
            }
          }
        }
      }
    } else if (mouseButton == LEFT) {
      if (firstClick && !marked) {
        ifFC = true;
      }
      if (!firstClick && !marked) {
        clicked = true;
        if (countBombs(r, c) == 0) {
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              if (!(i == 0 && j == 0)) {
                if (isValid(r+i, c+j) && !buttons[r+i][j+c].isClicked()) {
                  buttons[r+i][c+j].mousePressed();
                }
              }
            }
          }
        }
        if (!(countBombs(r, c) == 0 || bombs.contains(buttons[r][c]))) {
          setLabel(str(countBombs(r, c)));
        }
      }
    }

    if (firstClick && mouseButton == LEFT) {
      MSButton buttontemp;
      ArrayList<Integer> bombarr = new ArrayList<Integer>();
      buttontemp = buttons[0][0];
      for (MSButton[] buttona : buttons) {
        for (MSButton button : buttona) {
          if (button.firstClicked()) {
            buttontemp = button;
          }
        }
      }
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <=1; j++) {
          bombarr.add(buttontemp.getNum()+i+j*NUM_COLS);
        }
      }
      while (bombarr.size() < maxBombs + 9) {
        int randomnum = (int)(Math.random() * NUM_COLS * NUM_ROWS);
        if (randomnum == 0) {
          randomnum = 1;
        }
        if (!bombarr.contains(randomnum)) {
          bombarr.add(randomnum);
        }
      }
      for (int x = 0; x < 9; x++) {
        bombarr.remove(0);
      }
      for (Integer tempint : bombarr) {
        bombs.add(buttons[tempint/NUM_COLS][tempint%NUM_COLS]);
      }
      firstClick = false;
      buttontemp.mousePressed();
    }
    if (isLost) {
      isLost = false;
      firstClick = true;
      bombs = new ArrayList<MSButton>();
      textAlign(CENTER, CENTER);
      for (MSButton[] buttona : buttons) {
        for (MSButton button : buttona) {
          button.changeClickedF();
        }
      }
    }
    //your code here
  }

  public void draw () 
  {    
    if (marked) {
      fill(0);
    } else if ( clicked && bombs.contains(this) ) {
      isLost = true;
      fill(255, 0, 0);
    } else if (clicked) {
      fill( 200 );
    } else { 
      fill( 100 );
    }
    rect(x, y, width, height);
    fill(0);
    text(label, x+width/2, y+height/2);
  }
  public void setLabel(String newLabel)
  {
    label = newLabel;
  }
  public boolean isValid(int r, int c)
  {
    if (r >= 0 && r < NUM_ROWS) {
      if (c >= 0 && c < NUM_COLS ) {
        return true;
      }
    }
    return false;
  }
  public int countBombs(int row, int col)
  {
    int numBombs = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if ( isValid(row +j, col +i) && bombs.contains(buttons[row+j][col+i])) {
          numBombs++;
        }
      }
    }
    return numBombs;
  }
  public int countMarked(int row, int col)
  {
    int numM = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if ( isValid(row +j, col +i) && buttons[row+j][col+i].isMarked()) {
          numM++;
        }
      }
    }
    return numM;
  }
}
