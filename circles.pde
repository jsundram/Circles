int nCircles = int(random(50, 150));
ArrayList<Circle> circles = new ArrayList();
float new_circle_probability = .15;

Channel H = new Channel(50, 30);
Channel S = new Channel(100, 20);
Channel B = new Channel(150, 50);

boolean MOUSE_COLOR = false;

void setup()
{
    size(1920, 1080);
    
    frameRate(60);
    smooth();
    background(255);
    
    for (int i = 0; i < nCircles; i++)
    {
        circles.add(new Circle());
    }
}

class Channel
{
    float v, r, vmin, vmax;
    public Channel(float v, float r)
    {
        this.v = v;
        this.r = r;
        this.vmin = v - r;
        this.vmax = v + r; 
    }

    public void update(float value)
    {
        this.v = value;
        this.vmin = max(0, v - r);
        this.vmax = min(255, v + r);
    }

    public void increment(){ update((v + 1) % 255); }
    public float get(){ return random(vmin, vmax); }
    public float min_allowed(){ return r; }
    public float max_allowed(){ return 255 - r; }
}

class Circle
{
    float x;
    float y;
    float r;
    color c;
    float max_alpha;
    float stroke_weight;
    boolean filled;
    int lifetime;
    int age;
    
    PVector vel;
    public Circle()
    {
        this.randomize();
    }

    public void randomize()
    {
        x = random(0, width);
        y = random(0, height);
        r = random(0, min(width,height)/4);
        stroke_weight = r/8;
        filled = random(1) < .5;
        
        c = color(H.get(), S.get(), B.get());
        max_alpha = random(100, 200);
        
        vel = new PVector(random(-4, 4), random(-4, 4));
        
        age = 0;
        lifetime = int(random(120, 360));
    }

    public void update()
    {
        age += 1;
        x += vel.x;
        y += vel.y;
        if (x < 0 || width < x)
            vel.x = -vel.x;
        if (y < 0 || height < y)
            vel.y = -vel.y;
    }

    public boolean should_remove()
    {
        return lifetime < age;
    }

    public void draw()
    {
        if (should_remove())
            return;
        
        // current alpha
        float t_sq = lifetime * lifetime;
        float a = max_alpha - (4 * max_alpha / t_sq) * pow(age - sqrt(t_sq/4), 2);
        
        if (filled)
        {
            stroke(c, a);
            strokeWeight(stroke_weight * (1.0f - (float(age)/lifetime))); // dissolve
            noFill();
        }
        else
        {
            fill(c, a);
            noStroke();
        }
        
        ellipse(x, y, r, r);
    }
}


void draw()
{
    size(1920, 1080);
    background(255);
    
    colorMode(HSB, 255);
    H.increment();
    
    for (int i = 0; i < circles.size(); i++)
    {
        Circle c = circles.get(i);
        c.update();
        c.draw();
    }
    
    if (random(1) < new_circle_probability)
        circles.add(new Circle());
    
    for (int i = circles.size() - 1; i >= 0; i--)
        if (circles.get(i).should_remove())
            circles.remove(i);
}

void keyPressed()
{
    if (key == 'p')
        saveFrame("circles-####.png");
}

void mouseMoved()
{
    if (MOUSE_COLOR) // control saturation / brighness via mouse
    {
        S.update(map(mouseX, 0, width, S.min_allowed(), S.max_allowed()));
        B.update(map(mouseY, 0, height, B.min_allowed(), B.max_allowed()));
    }
}

void mouseClicked()
{
    Circle c = new Circle();
    c.x = mouseX;
    c.y = mouseY;
    c.c = color(H.v, S.v, B.v);
    c.max_alpha = 200; // make the added ones bright
    circles.add(c);
}
