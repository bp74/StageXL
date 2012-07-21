class ParticleColor 
{
  num red;
  num green;
  num blue;
  num alpha;
  
  ParticleColor([this.red = 0.0, this.green = 0.0, this.blue = 0.0, this.alpha = 0.0]);
  
  ParticleColor.fromJSON(Map json)
  {
    this.red = json["red"];
    this.green = json["green"];
    this.blue = json["blue"];
    this.alpha = json["alpha"];
  }
  
  
}
