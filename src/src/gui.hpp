#ifndef EZGBA_GUI_HPP
#define EZGBA_GUI_HPP

#if defined(GUI_SUPPORT) && GUI_SUPPORT == 1


#include <map>
#include <string>

#include <wx/wxprec.h>

#ifndef WX_PRECOMP
	#include <wx/wx.h>
#endif

#if !defined(wxUSE_THREADS) || !wxUSE_THREADS
	#error "wxWidgets thread support is required."
#else
	#include <wx/thread.h>
#endif

#include <wx/dynarray.h>
#include <wx/numdlg.h>
#include <wx/progdlg.h>


#include "data.hpp"
#include "misc.hpp"
#include "gui_base.h"





class MainFrame;

wxDECLARE_EVENT(wxEVT_COMMAND_PATCHING_COMPLETED, wxCommandEvent);



class PatchingThread : public wxThread {
public:
	PatchingThread(MainFrame * const handler, const std::map<std::string, std::string> & queue, const Options & opts);
	void * Entry(void);

private:
	std::map<std::string, std::string> queue;
	Options options;
	MainFrame * handler = NULL;
};



class MainFrame : public MainFrameBase {
public:
	// TODO Set window title.
	MainFrame(wxWindow * parent=NULL, wxWindowID id=wxID_ANY,
				 const wxString& title=wxEmptyString,
				 const wxPoint& pos=wxDefaultPosition, const wxSize& size = wxSize(-1, -1),
				 long style = wxDEFAULT_FRAME_STYLE|wxCLIP_CHILDREN|wxTAB_TRAVERSAL);

	~MainFrame() {
		// Better to do thread cleanup in OnClose() event handler, because event loop for top-level window
		// isn't active when its destructor is called. If the thread sends events when ending, they won't be processed,
		// unless you ended the thread from OnClose().
	}

	Options ToOptions();
	void UpdateOptions();
	void OnOptionsChanged() { this->UpdateOptions(); }

	void OnInputFileBtnClicked( wxCommandEvent& event );
	void OnClearInputBtnClicked( wxCommandEvent& event );
	void OnPatchBtnClicked( wxCommandEvent& event );

	void OnClose(wxCloseEvent &);

	void OnPatchingCompletion(wxCommandEvent & WXUNUSED(event));

protected:
	PatchingThread * patching_thread = NULL;

	wxDECLARE_EVENT_TABLE();
};



class App : public wxApp {
public:
	bool OnInit();
	int OnExit();
};



#endif //GUI_SUPPORT

#endif //EZGBA_GUI_HPP
