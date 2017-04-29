//
//
// Copyright 2017 RStagers <kf7ekb@gmail.com>
//
// This file is part of xlib++.
//
// xlib++ is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// xlib++ is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with xlib++; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//


// definition of the xlib::command_button class

#ifndef _xlib_toggle_button_class_
#define _xlib_toggle_button_class_

#include <string>
#include "display.hpp"
#include <X11/Xlib.h>
#include <sstream>
#include "command_button_base.hpp"
#include "command_button.hpp"
#include "color.hpp"
#include "shapes.hpp"
#include "window_base.hpp"
#include "graphics_context.hpp"
#include "pointer.hpp"


namespace xlib
{

  class toggle_button : public command_button
    {
    public:
      toggle_button ( window_base& parent, rectangle rect, std::string name, bool toggle_state=false ) 
	: command_button (  parent, rect, name ), m_toggle_state(toggle_state) {}


    virtual ~toggle_button()
	{
	  destroy();
	}

	// We capture this from the base class so we can set the toggle state. 
    virtual void on_left_button_up ( int x, int y )
	{
	  if ( m_is_down && m_is_mouse_over )
	    {
      	  if(m_toggle_state) 
			m_toggle_state = false;
	  	  else 
        	m_toggle_state = true; 
	      on_click();
	    }

	  m_is_down = false;
	  refresh();
	}


    virtual void on_expose()
	{

	  // draw the button
	  rectangle rect = get_rect();

	  graphics_context gc ( m_display, id() );

// I beieve to change the font you do something with the graphics context...
// I would like to be able to give a font to use along with size etc.
// I also need to implement get_toggle_state set_toggle_state...

	  color black ( m_display, 0, 0, 0 );
	  color white ( m_display, 255, 255, 255 );
	  color gray ( m_display, 131, 129, 131 );
	  color red (m_display, 192, 0, 0);

      if(!m_toggle_state)
	    gc.set_foreground ( black );
	  else
	    gc.set_foreground ( red );

	  // draw the text
	  rectangle text_rect = gc.get_text_rect ( m_name );
	  if ( m_is_down && m_is_mouse_over )
	    {
	      gc.draw_text ( point(rect.width()/2 - text_rect.width()/2 + 1,
			     rect.height()/2 + text_rect.height()/2 + 1 ),
			     m_name );
	    }
	  else
	    {
	      gc.draw_text ( point(rect.width()/2 - text_rect.width()/2,
			     rect.height()/2 + text_rect.height()/2),
			     m_name );
	    }

      gc.set_foreground ( black );

	  // draw the borders
	  if (!m_toggle_state)
	    {
	      // bottom
	      gc.draw_line ( line ( point(0,
					  rect.height()-1),
				    point(rect.width()-1,
					  rect.height()-1) ) );
	      // right
	      gc.draw_line ( line ( point ( rect.width()-1,
					    0 ),
				    point ( rect.width()-1,
					    rect.height()-1 ) ) );

	      gc.set_foreground ( white );

	      // top
	      gc.draw_line ( line ( point ( 0,0 ),
				    point ( rect.width()-2, 0 ) ) );
	      // left
	      gc.draw_line ( line ( point ( 0,0 ),
				    point ( 0, rect.height()-2 ) ) );

	      gc.set_foreground ( gray );

	      // bottom
	      gc.draw_line ( line ( point ( 1, rect.height()-2 ),
				    point(rect.width()-2,rect.height()-2) ) );
	      // right
	      gc.draw_line ( line ( point ( rect.width()-2, 1 ), 
				    point(rect.width()-2,rect.height()-2) ) );
	    }
	  else
	    {
	      gc.set_foreground ( white );

	      // bottom
	      gc.draw_line ( line ( point(1,rect.height()-1),
				    point(rect.width()-1,rect.height()-1) ) );
	      // right
	      gc.draw_line ( line ( point ( rect.width()-1, 1 ),
				    point ( rect.width()-1, rect.height()-1 ) ) );

	      gc.set_foreground ( black );

	      // top
	      gc.draw_line ( line ( point ( 0,0 ),
				    point ( rect.width()-1, 0 ) ) );
	      // left
	      gc.draw_line ( line ( point ( 0,0 ),
				    point ( 0, rect.height()-1 ) ) );


	      gc.set_foreground ( gray );

	      // top
	      gc.draw_line ( line ( point ( 1, 1 ),
				    point(rect.width()-2,1) ) );
	      // left
	      gc.draw_line ( line ( point ( 1, 1 ),
				    point( 1, rect.height()-2 ) ) );
	    }
	}


    private:

      toggle_button ( const toggle_button& );
      void operator = ( toggle_button& );

	  bool m_toggle_state;
	};
};

#endif
