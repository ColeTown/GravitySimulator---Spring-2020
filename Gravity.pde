int numberOfBodies = 5;
int trailSmoothness = 3;    //smaller numbers makes nicer trails but takes longer to run
float G = 10000.0;          //This is "gravitational constant" for this simulation. You can use the actual value if you want but I like to tweak it and see what happens. 
float pixelToMeter = 50.0;  //This just simply states how many meters one pixel is

Body bodies[] = new Body[numberOfBodies];
double distances[][] = new double[numberOfBodies][numberOfBodies];
PVector forces[][] = new PVector[numberOfBodies][numberOfBodies];
PGraphics canvas;
int halfWidth;
int halfHeight;

void setup() {
  fullScreen();
  frameRate(144);
  halfWidth = width/2;
  halfHeight = height/2;
  canvas = createGraphics(width, height);
  canvas.beginDraw();
  canvas.background(0);
  canvas.strokeWeight(1);
  canvas.stroke(255);
  canvas.endDraw();
  bodies[0] = new Body(100, 16, new PVector(0.0f, 0.0f), new PVector(0, 0), true);
  bodies[1] = new Body(10, 4, new PVector(400, 0), new PVector(0.0f, 1f), false);
  bodies[2] = new Body(10, 4, new PVector(-400, 0), new PVector(0.0f, -1f), false);
  bodies[3] = new Body(10, 4, new PVector(0, -400), new PVector(1.0f, 0.0f), false);
  bodies[4] = new Body(10, 4, new PVector(0, 400), new PVector(-1.0f, 0.0f), false);
  
  // This block of code will create random bodies that should orbit the central body. 
  
  //float x = 0;
  //float y = 0;
  //PVector temp;
  //for (int i = 1; i < numberOfBodies; i++) {
  //  x = random(-(halfWidth-100), (halfWidth-100));
  //  y = random(-(halfHeight-100), (halfHeight-100));
  //  temp = new PVector(x / (pow(PVector.dist(new PVector(0, 0), new PVector(x, y)) * pixelToMeter, 1.07)), y / (pow(PVector.dist(new PVector(0, 0), new PVector(x, y)) * pixelToMeter, 1.07)));
  //  temp.rotate(HALF_PI);
  //  temp.mult(random(.95, 1.05));
  //  bodies[i] = new Body(.01, random(1, 8), new PVector(x, y), temp, false);
  //}
}

void draw() {
  if (frameCount % trailSmoothness == 0) {
    image(canvas, 0, 0);
    translate(halfWidth, halfHeight);
    fill(255);
    stroke(255);
    for (int i = 0; i < numberOfBodies; i++) {
      setDistances();
      setForces();
      bodies[i].update(i);
      bodies[i].draw();
    }
    canvas.beginDraw();
    canvas.background(0, 5);
    canvas.endDraw();
    println(frameRate);
  } else {
    for (int i = 0; i < numberOfBodies; i++) {
      setDistances();
      setForces();
      bodies[i].update(i);
    }
  }
}

void setDistances() {
  float temp = 0;
  for (int i = 0; i < numberOfBodies; i++) {
    for (int j = 0; j < i; j++) {
      temp = PVector.dist(bodies[i].position, bodies[j].position);
      distances[i][j] = temp;
      distances[j][i] = temp;
    }
  }
}

void setForces() { //from i to j
  double f = 0;
  PVector temp;
  for (int i = 0; i < numberOfBodies; i++) {
    for (int j = 0; j < i; j++) {
      if (i != j) {
        f = (G * bodies[i].mass * bodies[j].mass) / Math.pow((float)distances[i][j] * pixelToMeter, 2);
        temp = new PVector(bodies[j].position.x - bodies[i].position.x, bodies[j].position.y - bodies[i].position.y);
        temp.normalize();
        temp.mult((float)f);
        forces[i][j] = temp;
        forces[j][i] = new PVector(-temp.x, -temp.y);
      }
    }
  }
}

class Body {

  public float mass;
  private float size;
  private PVector drawPosition = new PVector();
  private PVector position = new PVector(); //null pointer exceptin here means you have too many numberOfBodies
  private PVector velocity = new PVector();
  private PVector acceleration = new PVector();
  private PVector force = new PVector();
  private boolean staticPosition;

  public Body(float mass, float size, PVector pos, PVector initialVelocity, boolean staticPosition) {
    this.staticPosition = staticPosition;
    this.mass = mass;
    this.size = size;
    this.position = pos;
    this.drawPosition.x = pos.x;
    this.drawPosition.y = pos.y;
    this.velocity = initialVelocity;
  }

  public void update(int i) {
    if (!this.staticPosition) {
      getForces(i);
      acceleration.set(force.div(mass));
      velocity.add(acceleration);
      position.add(velocity);
    }
  }

  public void draw() {
    circle(position.x, position.y, size);
  }

  private void getForces(int i) {
    force.x = 0;
    force.y = 0;
    for (int j = 0; j < numberOfBodies; j++) {
      if (i != j) {
        force.add(forces[i][j]);
      }
    }
  }
}
