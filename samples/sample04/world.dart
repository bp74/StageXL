class World extends Sprite
{
  World(Resource resource)
  { 
    // the sun ...
    
    Bitmap sun = new Bitmap(resource.getBitmapData("sun"));
    sun.x = 100;
    sun.y = 0;
    sun.scaleX = 0.5;
    sun.scaleY = 0.5;
    this.addChild(sun);
    
    // and a tree ... 
    
    Bitmap tree = new Bitmap(resource.getBitmapData("tree"));
    tree.x = 0;
    tree.y = 30;
    tree.scaleX = 0.7;
    tree.scaleY = 0.7;
    this.addChild(tree);

    // and a house ...
    
    Bitmap house = new Bitmap(resource.getBitmapData("house"));
    house.x = 30;
    house.y = 40;
    this.addChild(house);
  }
  
}
