int nCircles = int(random(50, 150));
ArrayList<Circle> circles = new ArrayList();
float new_circle_probability = .15;
float H = 50;
float H_RADIUS = 30;
float H_MIN, H_MAX;


void setup()
{
    size(window.innerWidth, window.innerHeight);

    frameRate(60);
    smooth();
    background(255);
    
    for (int i = 0; i < nCircles; i++)
    {
        circles.add(new Circle());
    }
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
    int age = 0;
    
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
        
        c = color(random(H_MIN, H_MAX), random(80, 120), random(100, 200));    
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
        return lifetime <= age;
    }
    
    public void draw()
    {
        if (lifetime < age)
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
    size(window.innerWidth, window.innerHeight);

    H = (H + 1) % 255;
    H_MIN = max(0, H - H_RADIUS);
    H_MAX = min(255, H + H_RADIUS);
    
    // Fade?
    if (false)
    {
        noStroke();
        fill(255, 30);    
        rect(0, 0, width, height);
    }
    else
        background(255);
    
    
    colorMode(HSB, 255);
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
