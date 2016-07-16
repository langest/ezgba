///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Jun 17 2015)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __GUI_BASE_H__
#define __GUI_BASE_H__

#include <wx/artprov.h>
#include <wx/xrc/xmlres.h>
#include <wx/string.h>
#include <wx/stattext.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/button.h>
#include <wx/sizer.h>
#include <wx/listbox.h>
#include <wx/statline.h>
#include <wx/checkbox.h>
#include <wx/filepicker.h>
#include <wx/frame.h>

///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/// Class MainFrameBase
///////////////////////////////////////////////////////////////////////////////
class MainFrameBase : public wxFrame 
{
	private:
	
	protected:
		wxStaticText* input_lbl;
		wxButton* input_filepicker_btn;
		wxButton* clear_input_btn;
		wxListBox* input_file_list;
		wxStaticLine* m_staticline3;
		wxCheckBox* sram_cbx;
		wxCheckBox* uniformize_cbx;
		wxCheckBox* ez4_cbx;
		wxCheckBox* complement_check_cbx;
		wxCheckBox* trim_cbx;
		wxCheckBox* dummy_save_cbx;
		wxCheckBox* ips_cbx;
		wxFilePickerCtrl* ips_filepicker;
		wxStaticLine* m_staticline2;
		wxButton* patch_btn;
		wxCheckBox* modify_in_place_cbx;
		
		// Virtual event handlers, overide them in your derived class
		virtual void OnInputFileBtnClicked( wxCommandEvent& event ) { event.Skip(); }
		virtual void OnClearInputBtnClicked( wxCommandEvent& event ) { event.Skip(); }
		virtual void ClearInputFileListBoxSelection( wxUpdateUIEvent& event ) { event.Skip(); }
		virtual void OnOptionsChanged( wxCommandEvent& event ) { event.Skip(); }
		virtual void OnOptionsChanged( wxFileDirPickerEvent& event ) { event.Skip(); }
		virtual void OnPatchBtnClicked( wxCommandEvent& event ) { event.Skip(); }
		
	
	public:
		
		MainFrameBase( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxEmptyString, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( -1,-1 ), long style = wxDEFAULT_FRAME_STYLE|wxCLIP_CHILDREN|wxTAB_TRAVERSAL );
		
		~MainFrameBase();
	
};

#endif //__GUI_BASE_H__
