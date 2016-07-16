///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Jun 17 2015)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#include "gui_base.h"

///////////////////////////////////////////////////////////////////////////

MainFrameBase::MainFrameBase( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxFrame( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxDefaultSize, wxDefaultSize );
	this->SetBackgroundColour( wxSystemSettings::GetColour( wxSYS_COLOUR_WINDOW ) );
	
	wxBoxSizer* main_boxsizer;
	main_boxsizer = new wxBoxSizer( wxVERTICAL );
	
	wxBoxSizer* bSizer1;
	bSizer1 = new wxBoxSizer( wxVERTICAL );
	
	wxBoxSizer* bSizer5;
	bSizer5 = new wxBoxSizer( wxHORIZONTAL );
	
	input_lbl = new wxStaticText( this, wxID_ANY, wxT("Input ROM(s)"), wxDefaultPosition, wxDefaultSize, 0 );
	input_lbl->Wrap( -1 );
	bSizer5->Add( input_lbl, 0, wxALIGN_CENTER_VERTICAL|wxALL, 5 );
	
	input_filepicker_btn = new wxButton( this, wxID_ANY, wxT("Select ROM(s)"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer5->Add( input_filepicker_btn, 0, wxALL, 5 );
	
	clear_input_btn = new wxButton( this, wxID_ANY, wxT("Clear Queue"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer5->Add( clear_input_btn, 0, wxALL, 5 );
	
	
	bSizer1->Add( bSizer5, 0, wxALL|wxEXPAND, 5 );
	
	input_file_list = new wxListBox( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0, NULL, wxLB_NEEDED_SB|wxLB_SORT ); 
	input_file_list->SetMinSize( wxSize( -1,75 ) );
	
	bSizer1->Add( input_file_list, 0, wxALIGN_CENTER_HORIZONTAL|wxALL|wxEXPAND, 5 );
	
	m_staticline3 = new wxStaticLine( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLI_HORIZONTAL );
	bSizer1->Add( m_staticline3, 0, wxEXPAND | wxALL, 5 );
	
	wxBoxSizer* bSizer15;
	bSizer15 = new wxBoxSizer( wxVERTICAL );
	
	bSizer15->SetMinSize( wxSize( -1,250 ) ); 
	
	bSizer1->Add( bSizer15, 1, wxEXPAND, 5 );
	
	wxGridSizer* gSizer1;
	gSizer1 = new wxGridSizer( 0, 2, 0, 0 );
	
	sram_cbx = new wxCheckBox( this, wxID_ANY, wxT("Patch save type to SRAM"), wxDefaultPosition, wxDefaultSize, 0 );
	sram_cbx->SetValue(true); 
	gSizer1->Add( sram_cbx, 0, wxALL, 5 );
	
	uniformize_cbx = new wxCheckBox( this, wxID_ANY, wxT("Uniformize ROM padding"), wxDefaultPosition, wxDefaultSize, 0 );
	gSizer1->Add( uniformize_cbx, 0, wxALL, 5 );
	
	ez4_cbx = new wxCheckBox( this, wxID_ANY, wxT("EZ4 header patch"), wxDefaultPosition, wxDefaultSize, 0 );
	ez4_cbx->SetValue(true); 
	gSizer1->Add( ez4_cbx, 0, wxALL, 5 );
	
	complement_check_cbx = new wxCheckBox( this, wxID_ANY, wxT("Correct complement checksum"), wxDefaultPosition, wxDefaultSize, 0 );
	complement_check_cbx->SetValue(true); 
	gSizer1->Add( complement_check_cbx, 0, wxALL, 5 );
	
	trim_cbx = new wxCheckBox( this, wxID_ANY, wxT("Trim padding"), wxDefaultPosition, wxDefaultSize, 0 );
	gSizer1->Add( trim_cbx, 0, wxALL, 5 );
	
	dummy_save_cbx = new wxCheckBox( this, wxID_ANY, wxT("Create dummy save file(s)"), wxDefaultPosition, wxDefaultSize, 0 );
	gSizer1->Add( dummy_save_cbx, 0, wxALL, 5 );
	
	
	bSizer1->Add( gSizer1, 0, wxALL|wxEXPAND, 5 );
	
	wxBoxSizer* bSizer3;
	bSizer3 = new wxBoxSizer( wxHORIZONTAL );
	
	ips_cbx = new wxCheckBox( this, wxID_ANY, wxT("IPS patch"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer3->Add( ips_cbx, 0, wxALIGN_CENTER_VERTICAL|wxALL, 5 );
	
	ips_filepicker = new wxFilePickerCtrl( this, wxID_ANY, wxEmptyString, wxT("Select a file"), wxT("IPS Patch Files (*.ips)|*.ips|All files (*.*)|*.*"), wxDefaultPosition, wxDefaultSize, wxFLP_DEFAULT_STYLE|wxFLP_USE_TEXTCTRL );
	ips_filepicker->SetBackgroundColour( wxSystemSettings::GetColour( wxSYS_COLOUR_WINDOW ) );
	
	bSizer3->Add( ips_filepicker, 1, wxALIGN_CENTER_VERTICAL|wxALIGN_RIGHT|wxALL, 5 );
	
	
	bSizer1->Add( bSizer3, 0, wxALL|wxEXPAND, 5 );
	
	m_staticline2 = new wxStaticLine( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLI_HORIZONTAL );
	bSizer1->Add( m_staticline2, 0, wxEXPAND | wxALL, 5 );
	
	wxBoxSizer* bSizer11;
	bSizer11 = new wxBoxSizer( wxVERTICAL );
	
	wxBoxSizer* bSizer9;
	bSizer9 = new wxBoxSizer( wxVERTICAL );
	
	wxBoxSizer* bSizer8;
	bSizer8 = new wxBoxSizer( wxHORIZONTAL );
	
	
	bSizer8->Add( 0, 0, 1, wxEXPAND, 5 );
	
	patch_btn = new wxButton( this, wxID_ANY, wxT("Patch"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer8->Add( patch_btn, 1, wxALIGN_CENTER|wxALL, 5 );
	
	modify_in_place_cbx = new wxCheckBox( this, wxID_ANY, wxT("Modify in-place"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer8->Add( modify_in_place_cbx, 0, wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL|wxALL, 5 );
	
	
	bSizer8->Add( 0, 0, 1, wxEXPAND, 5 );
	
	
	bSizer9->Add( bSizer8, 1, wxALIGN_CENTER_HORIZONTAL|wxEXPAND, 5 );
	
	
	bSizer11->Add( bSizer9, 1, wxEXPAND, 10 );
	
	
	bSizer1->Add( bSizer11, 0, wxALL|wxEXPAND, 5 );
	
	
	main_boxsizer->Add( bSizer1, 1, wxALL|wxEXPAND, 10 );
	
	
	this->SetSizer( main_boxsizer );
	this->Layout();
	main_boxsizer->Fit( this );
	
	this->Centre( wxBOTH );
	
	// Connect Events
	input_filepicker_btn->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( MainFrameBase::OnInputFileBtnClicked ), NULL, this );
	clear_input_btn->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( MainFrameBase::OnClearInputBtnClicked ), NULL, this );
	input_file_list->Connect( wxEVT_UPDATE_UI, wxUpdateUIEventHandler( MainFrameBase::ClearInputFileListBoxSelection ), NULL, this );
	sram_cbx->Connect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	uniformize_cbx->Connect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	ez4_cbx->Connect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	complement_check_cbx->Connect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	trim_cbx->Connect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	dummy_save_cbx->Connect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	ips_cbx->Connect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	ips_filepicker->Connect( wxEVT_COMMAND_FILEPICKER_CHANGED, wxFileDirPickerEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	patch_btn->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( MainFrameBase::OnPatchBtnClicked ), NULL, this );
	modify_in_place_cbx->Connect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
}

MainFrameBase::~MainFrameBase()
{
	// Disconnect Events
	input_filepicker_btn->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( MainFrameBase::OnInputFileBtnClicked ), NULL, this );
	clear_input_btn->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( MainFrameBase::OnClearInputBtnClicked ), NULL, this );
	input_file_list->Disconnect( wxEVT_UPDATE_UI, wxUpdateUIEventHandler( MainFrameBase::ClearInputFileListBoxSelection ), NULL, this );
	sram_cbx->Disconnect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	uniformize_cbx->Disconnect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	ez4_cbx->Disconnect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	complement_check_cbx->Disconnect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	trim_cbx->Disconnect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	dummy_save_cbx->Disconnect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	ips_cbx->Disconnect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	ips_filepicker->Disconnect( wxEVT_COMMAND_FILEPICKER_CHANGED, wxFileDirPickerEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	patch_btn->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( MainFrameBase::OnPatchBtnClicked ), NULL, this );
	modify_in_place_cbx->Disconnect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( MainFrameBase::OnOptionsChanged ), NULL, this );
	
}
