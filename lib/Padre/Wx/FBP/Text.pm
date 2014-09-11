package Padre::Wx::FBP::Text;

## no critic

# This module was generated by Padre::Plugin::FormBuilder::Perl.
# To change this module edit the original .fbp file and regenerate.
# DO NOT MODIFY THIS FILE BY HAND!

use 5.008005;
use utf8;
use strict;
use warnings;
use Padre::Wx ();
use Padre::Wx::Role::Main ();

our $VERSION = '1.01';
our @ISA     = qw{
	Padre::Wx::Role::Main
	Wx::Dialog
};

sub new {
	my $class  = shift;
	my $parent = shift;

	my $self = $class->SUPER::new(
		$parent,
		-1,
		'',
		Wx::DefaultPosition,
		[ 300, 300 ],
		Wx::DEFAULT_DIALOG_STYLE | Wx::RESIZE_BORDER,
	);

	$self->{text} = Wx::TextCtrl->new(
		$self,
		-1,
		"",
		Wx::DefaultPosition,
		Wx::DefaultSize,
		Wx::TE_MULTILINE,
	);
	$self->{text}->SetMinSize( [ 250, 250 ] );

	my $m_staticline1 = Wx::StaticLine->new(
		$self,
		-1,
		Wx::DefaultPosition,
		Wx::DefaultSize,
		Wx::LI_HORIZONTAL,
	);

	$self->{close} = Wx::Button->new(
		$self,
		Wx::ID_CANCEL,
		Wx::gettext("Close"),
		Wx::DefaultPosition,
		Wx::DefaultSize,
	);
	$self->{close}->SetDefault;

	my $buttons = Wx::BoxSizer->new(Wx::HORIZONTAL);
	$buttons->Add( 20, 0, 1, Wx::EXPAND, 5 );
	$buttons->Add( $self->{close}, 0, Wx::ALL, 5 );

	my $vsizer = Wx::BoxSizer->new(Wx::VERTICAL);
	$vsizer->Add( $self->{text}, 1, Wx::ALL | Wx::EXPAND, 5 );
	$vsizer->Add( $m_staticline1, 0, Wx::ALL | Wx::EXPAND, 5 );
	$vsizer->Add( $buttons, 0, Wx::EXPAND, 5 );

	my $hsizer = Wx::BoxSizer->new(Wx::HORIZONTAL);
	$hsizer->Add( $vsizer, 1, Wx::EXPAND, 5 );

	$self->SetSizer($hsizer);
	$self->Layout;

	return $self;
}

sub text {
	$_[0]->{text};
}

sub close {
	$_[0]->{close};
}

1;

# Copyright 2008-2014 The Padre development team as listed in Padre.pm.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.

