/* removes all formatting from sorce code */
#include <fstream>
#include <string>
#include <iterator>
#include <iostream>

using namespace std;

string unformat(const string &code)
{
  string result = "";
  bool last_word = false, sp_sep = false;
  for (auto ch : code)
  {
    if (isalnum(ch) || ch == '_')
    {
      if (last_word && sp_sep)
        result += ' ';
      result += ch;
      last_word = true;
      sp_sep = false;
    }
    else if (isspace(ch))
    {
      sp_sep = true;
    }
    else
    {
      result += ch;
      last_word = sp_sep = false;
    }
  }
  return result;
}

int main(int argc, char **argv)
{
  ifstream file(argv[1]);
  string text((istreambuf_iterator<char>(file)),
               istreambuf_iterator<char>());

  cout << unformat(text) << endl;
}

