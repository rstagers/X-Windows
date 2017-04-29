//
// Simple X-Windows with a Command Button "widget" and a derive Toggle Button widget.
//

#include "xlib++/display.hpp"
#include "xlib++/window.hpp"
#include "xlib++/graphics_context.hpp"
#include "xlib++/command_button.hpp"
#include "xlib++/toggle_button.hpp"

using namespace xlib;
class main_window;


class hello_toggle : public toggle_button
{
public:
  hello_toggle ( main_window& w );
  ~hello_toggle(){}

  void on_click();

private:
  main_window& m_parent;
};

class hello_button : public command_button
{
public:
  hello_button ( main_window& w );
  ~hello_button(){}

  void on_click();

private:
  main_window& m_parent;
};


class main_window : public window
{
 public:
  main_window ( event_dispatcher& e )  : window ( e )
  { 
    set_title("Hello X Windows World");
    m_hello = new hello_button ( *this ); 
    m_toggle = new hello_toggle ( *this ); 
    
    color_red = new color(m_toggle->get_display(), 255, 0, 0); 
  }
  
 ~main_window(){ delete m_hello; delete m_toggle; delete color_red; }
  
  void on_hello_click() { std::cout << "hello_click()\n"; }
  void on_toggle_click() { std::cout << "toggle_click()\n"; }
private:

  color* color_red;
  hello_button* m_hello;
  hello_toggle* m_toggle;
};


//
// Hello button
//
hello_button::hello_button ( main_window& w )
  : command_button ( w, rectangle(point(20,20),100,30 ), "hello" ),
    m_parent ( w )
{}
void hello_button::on_click() { m_parent.on_hello_click(); }

hello_toggle::hello_toggle ( main_window& w )
  : toggle_button ( w, rectangle(point(20,60),100,30 ), "toggle" ),
    m_parent ( w )
{}
void hello_toggle::on_click() { m_parent.on_toggle_click(); }

int main()
{
  try
    {
      // Open a display.
      display d("");

      event_dispatcher events ( d ); 
      main_window w ( events ); // top-level
      events.run();
    }
  catch ( exception_with_text& e )
    {
      std::cout << "Exception: " << e.what() << "\n";
    }
  return 0;
}
