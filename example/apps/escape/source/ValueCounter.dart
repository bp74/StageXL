class ValueCounter
{
  int value = 0;

  int increment([int inc = 1]) => (value += inc);
  int decrement([int dec = 1]) => (value -= dec);
}
