tile[] tiles;
int time;
int[] trackClicked = new int[100];
int[] track = new int[100];
boolean keep = false;

int score = 0;
boolean inMenu = true;
boolean inDiffMenu = false;
boolean over = false;
int difficulty = 2; 
String[] difficulties = {"Easy", "Normal", "Hard"}; 
String selectedDifficulty = difficulties[difficulty - 1];
int numCards =20; // Numărul implicit de cărți
int numImages = 10;
int numRows;
int numCols;
int[] numberList; 
int[] show = new int[numCards]; // Ajustăm lungimea tabloului show în funcție de numărul de cărți
int[] bestScores = {12, 16, 20};
boolean firstGame = true;
void setup() {
  size(1000, 1000);
  
  for (int i = 0; i < 100; i++) {
    trackClicked[i] = 0;
    track[i] = 0;
  }
}

void randomize(int[] a) { 
  int temp;
  for (int i = 0; i < a.length; i++) {
    int pick = (int)random(a.length);
    temp = a[i];
    a[i] = a[pick];
    a[pick] = temp;
  }
}

void draw() {
  if (inMenu) {
    drawMenu();
  } else if (inDiffMenu) {
    displayDifficultyMenu();
  } else {
    drawGame();
    updateGame();
  }
}

void startGame() {
  inMenu = false;
  
   if (difficulty == 1) {
    numCards = 12;
    numRows = 3;
    numCols = 4;
  } else if (difficulty == 2) {
    numCards = 16;
    numRows = 4;
    numCols = 4;
  } else if (difficulty == 3) {
    numCards = 20;
    numRows = 4;
    numCols = 5;
  }
  
  // Actualizăm dimensiunile cardurilor în funcție de numărul de rânduri și coloane
  int cardWidth = 120;
  int cardHeight = 120;
  
  numberList = new int[numCards];
  for (int i = 0; i < numCards/2; i++) {
    numberList[i] = i % numImages + 1;
    numberList[i + numCards/2] = i % numImages + 1;
  }
  randomize(numberList);
  
  
  
  // Inițializăm cardurile cu noile dimensiuni și numere
  tiles = new tile[numCards];
  for (int i = 0; i < tiles.length; i++) {
    tiles[i] = new tile(numberList[i], cardWidth, cardHeight);
    tiles[i].reveal = false;
    show[i] = 0;
  }
}

void drawMenu() {
  background(0);
  fill(255);
  textSize(50);
  textAlign(CENTER, CENTER);
  text("Memory Game", width/2, height/2 - 50);
  textSize(30);
  text("Click to Start", width/2, height/2 + 50);
  text("Press 'Q' to Quit", width/2, height/2 + 100);
  text("Press 'D' to Change Difficulty", width/2, height/2 + 150);
  text("R for restart", width/2, height/2 + 200);
  textSize(20);
  text("Selected Difficulty: " + selectedDifficulty, width/2, height/2 + 250);
}

void drawGame() {
  background(0);
  rectMode(CENTER);
  int trueTiles = 0;
  for (int i = 0; i < tiles.length; i++) {
    int row = i / numCols;
    int col = i % numCols;
    int x = 140 * (col + 1) - 50;
    int y = 140 * (row + 1) - 50;
    
    // Draw the tile rectangle
    fill(100); // Placeholder color
    rect(x, y, tiles[i].tileWidth, tiles[i].tileHeight);
    
    if (tiles[i].reveal) {
      // Draw the image within the tile rectangle
      imageMode(CENTER);
      image(tiles[i].tileColor, x, y, tiles[i].tileWidth, tiles[i].tileHeight);
    }
    
    // Draw a border around the tiles
    noFill();
    stroke(255);
    rect(x, y, tiles[i].tileWidth, tiles[i].tileHeight);
    
    if (tiles[i].reveal) {
      trueTiles++;
    }
  }
   fill(255);
  textSize(30);
  text("Score: " + score/2, 830, 50);
  text("Best Score: " + bestScores[difficulty - 1], 830, 100);
  
}




void updateGame() {
  int trueTiles = 0;
  for (int i = 0; i < tiles.length; i++) {
    if (time > 1 && time % 2 != 0) {
      if ((track[time - 3] != track[time - 2])) {
        tiles[trackClicked[time - 3]].reveal = false;
        tiles[trackClicked[time - 2]].reveal = false;
      } else {
        tiles[trackClicked[time - 3]].reveal = true;
        tiles[trackClicked[time - 2]].reveal = true;
      }
    }
    if (tiles[i].reveal == true) {
      trueTiles++;
    }
  }
  if (trueTiles == tiles.length) {
    gameOver();
  }
}

void mouseClicked() {
   if (!inMenu && !inDiffMenu) {
    boolean cardSelected = false; // Variabilă pentru a ține evidența dacă a fost selectată o carte
    int selectedCardIndex = -1; // Indexul cărții selectate
    
    for (int i = 0; i < tiles.length; i++) {
      int row = i / numCols;
      int col = i % numCols;
      int x = 140 * (col + 1) - 50;
      int y = 140 * (row + 1) - 50;
      
      if (mouseX <= x + tiles[i].tileWidth/2 && mouseX >= x - tiles[i].tileWidth/2 && mouseY >= y - tiles[i].tileHeight/2 && mouseY <= y + tiles[i].tileHeight/2 && tiles[i].reveal == false) {
        tiles[i].reveal = true;
        time++;
        track[time-1] = tiles[i].number;
        trackClicked[time-1] = i;
        score++;
        
        // Verificăm dacă este deja selectată o carte
        if (!cardSelected) {
          cardSelected = true;
          selectedCardIndex = i;
        } else {
          // Dacă este deja selectată o carte, verificăm dacă este o pereche corectă
          int prevIndex = selectedCardIndex;
          int currentIndex = i;
          if (tiles[prevIndex].number == tiles[currentIndex].number) {
            // Cărțile sunt aceleași, le păstrăm deschise
            tiles[prevIndex].reveal = true;
            tiles[currentIndex].reveal = true;
          } else {
            // Cărțile sunt diferite, le întoarcem înapoi după o scurtă întârziere
            tiles[prevIndex].reveal = false;
            tiles[currentIndex].reveal = false;
          }
          // Resetăm variabilele pentru următoarea selecție
          cardSelected = false;
          selectedCardIndex = -1;
        }
      }
    }
  }
   else if (inDiffMenu) {
    if (mouseY > 80 && mouseY < 120) {
      if (mouseX > width/4 - 50 && mouseX < width/4 + 50) {
        difficulty = 1;
      } else if (mouseX > width/2 - 60 && mouseX < width/2 + 60) {
        difficulty = 2;
      } else if (mouseX > 3*width/4 - 50 && mouseX < 3*width/4 + 50) {
        difficulty = 3;
      }
      selectedDifficulty = difficulties[difficulty - 1];
      inDiffMenu = false;
      inMenu = true;
    }
  } else {
    startGame();
  }
}


void keyPressed() {
  if (key == 'q' || key == 'Q') {
    exit();
  }
  
  else if (key == 'r' || key == 'R') {
    restartGame(); // Apelăm funcția restartGame() atunci când jucătorul apasă tasta 'R'
  }
  
  else if(key == 'd' || key == 'D'){
    displayDifficultyMenu();  
  }
}

void restartGame() {
  inMenu = true; // Revenim la ecranul de meniu
  over = false; // Resetăm variabila over
  score = 0; // Resetăm scorul
  time = 0; // Resetăm timpul
  // Resetați alte variabile necesare pentru joc
  setup(); // Inițializăm jocul din nou
}

void gameOver() {
  fill(255);
  textSize(50);
  text("YOU WIN", width/2, 800);
  int currentBestScore = bestScores[difficulty - 1]; // Scorul curent pentru dificultatea curentă
  if (firstGame || score/2 < currentBestScore) { // Verificăm dacă este primul joc sau dacă scorul actual este mai bun decât "best score" anterior
    bestScores[difficulty - 1] = score/2; // Actualizăm "best score" pentru dificultatea curentă
    firstGame = false; // Marcam că nu mai este primul joc
  }
  text("Score: " + score/2, width/2, 850);
  text("Best Score: " + bestScores[difficulty - 1], width/2, 900); // Afișăm "best score"
  over = true;
}

void displayDifficultyMenu() {
  inMenu = false;
  inDiffMenu = true;
  fill(0);
  textSize(24);
  text("Select Difficulty", width/2, 50);
  textSize(18);
  fill(150);
  text("Easy", width/4, 100);
  text("Normal", width/2, 100);
  text("Hard", 3*width/4, 100);
  fill(0, 255, 0, 100);
  if (difficulty == 1) {
    rect(width/4 - 50, 80, 100, 40);
  } else if (difficulty == 2) {
    fill(0, 0, 255, 100);
    rect(width/2 - 60, 80, 120, 40);
  } else if (difficulty == 3) {
    fill(255, 0, 0, 100);
    rect(3*width/4 - 50, 80, 100, 40);
  }
}

class tile {
  int x;
  int y;
  PImage tileColor;
  boolean reveal;
  int number;
  int tileWidth;
  int tileHeight;
  PImage[] images;
  
  tile(int colorNumber, int width, int height) {
    reveal = false;
    tileWidth = width;
    tileHeight = height;
    number = colorNumber;
    // Încărcăm numărul corect de imagini în funcție de dificultate
    images = new PImage[numImages];
    for (int i = 0; i < numImages; i++) {
      images[i] = loadImage("img" + (i + 1) + ".jpg");
    }
    tileColor = images[number - 1];
  }
}
