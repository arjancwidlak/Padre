package Padre::Wx::ErrorList;

use strict;
use warnings;
use Encode                   ();
use Padre::Wx                ();
use Padre::Locale            ();
use Padre::Task::ErrorParser ();
use Parse::ErrorString::Perl ();

our $VERSION = '0.25';
our @ISA     = 'Wx::TreeCtrl';

use Class::XSAccessor
	getters => {
		root     => 'root',
		data     => 'data',
		enabled  => 'enabled',
		index    => 'index',
		lang     => 'lang',
		parser   => 'parser',
	};

sub new {
	my $class  = shift;
	my $main   = shift;

	# Create the Wx object
	my $self = $class->SUPER::new(
		$main->bottom, 
		-1, 
		Wx::wxDefaultPosition, 
		Wx::wxDefaultSize, 
		Wx::wxTR_HAS_BUTTONS
		| Wx::wxTR_HIDE_ROOT
		| Wx::wxTR_LINES_AT_ROOT
	);

	$self->Hide;

	$self->{root} = $self->AddRoot(
		'Root',
		-1,
		-1,
		Wx::TreeItemData->new('Data'),
	);	

	Wx::Event::EVT_TREE_ITEM_ACTIVATED( $self,
		$self,
		sub {
			$self->on_tree_item_activated($_[1])
		},
	);

	return $self;
}

sub bottom {
	$_[0]->GetParent;
}

sub main {
	$_[0]->GetGrandParent;
}

sub config {
	$_[0]->GetGrandParent->config;
}

sub enable {
	my $self     = shift;
	my $main     = $self->main;
	my $bottom   = $self->bottom;
	my $position = $bottom->GetPageCount;
	$bottom->InsertPage( $position, $self, Wx::gettext("Error List"), 0 );
	$self->Show;
	$bottom->SetSelection($position);
	$main->aui->Update;
	$self->{enabled} = 1;
}

sub disable {
	my $self     = shift;
	my $main     = $self->main;
	my $bottom   = $self->bottom;
	my $position = $bottom->GetPageIndex($self);
	$self->Hide;
	$bottom->RemovePage($position);
	$main->aui->Update;
	$self->{enabled} = 0;
}

sub populate {
	my $self = shift;
	return unless $self->enabled;

	my $lang = $self->config->locale_perldiag;
	$lang =~ s/^\s*//;
	$lang =~ s/\s*$//;
	my $old = $self->lang;
	$self->{lang} = $lang;

	my $data = $self->data;
	$self->{data} = "";
	return unless $data;

	my $task = Padre::Task::ErrorParser->new(
		parser   => $self->parser,
		cur_lang => $lang,
		old_lang => $old,
		data     => $data,
	);

	$task->schedule;
}

sub on_menu_help_context_help {
	my $self  = shift;
	my $item  = $self->GetSelection or return;
	my $error = $self->GetPlData($item);
	if ( $error->isa('Parse::ErrorString::Perl::StackItem') ) {
		return;
	}
	my $diagnostics = Wx::gettext("No diagnostics available for this error!");
	if ($error->diagnostics) {
		$diagnostics = $error->diagnostics;
		$diagnostics =~ s/[A-Z]<(.*?)>/$1/sg;
	}
	$diagnostics = Padre::Util::WIN32
		? $diagnostics
		: Encode::encode('utf8', $diagnostics);
	my $dialog_title = Wx::gettext("Diagnostics");
	if ($error->type_description) {
		$dialog_title .= (": " . Wx::gettext($error->type_description));
	}
	my $dialog = Wx::MessageDialog->new(
		$self->main,
		$diagnostics,
		$dialog_title,
		Wx::wxOK,
	);
	$dialog->ShowModal;
}

sub on_tree_item_activated {
	my $self  = shift;
	my $event = shift;
	my $item  = $event->GetItem or return;
	my $error = $self->GetPlData($item);
	my $main  = $self->main;
	if ( $error->file eq 'eval' ) {
		return;
	}
	$main->setup_editor($error->file_abspath);
	my $editor = $main->current->editor;
	my $line   = $error->line - 1;
	$editor->goto_line_centerize($line);
}

sub collect_data {
	my $self = shift;
	return unless $self->enabled;
	my $line = shift;
	#if (!$self->{data}) {
	#    my $root = $self->root;
	#    $self->DeleteChildren($root);
	#}
	$self->{data} .= $line;
	$self->{data} .= "\n";
}

sub clear {
	my $self = shift;
	$self->DeleteChildren($self->root);
}

1;

# Copyright 2008 Gabor Szabo.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.

