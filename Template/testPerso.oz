%IsNote
%IsChord
%IsExtendedNote
%ChordToextended
%IsTransformation

declare 

%\insert '/home/theo/Code/Oz/MaestrOZ/Template/code.oz' 

NoteTrue = note(name:Name octave:4 sharp:true duration:1.0 instrument:none)
NoteFalse = nut(name:Name octave:4 sharp:true duration:1.0 instrument:none)

{Browse 'IsNote(NoteTrue) --> should print true'}
{Browse {IsNote NoteTrue}}

{Browse 'IsNote(NoteFalse) --> should print false'}
{Browse {IsNote NoteFalse}}

