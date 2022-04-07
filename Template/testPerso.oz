%IsNote
%IsChord
%IsExtendedNote
%ChordToextended
%IsTransformation

\insert '/home/theo/Code/Oz/MaestrOZ/Template/code.oz' 

declare 
NoteTrue = note(name:Name octave:4 sharp:true duration:1.0 instrument:none)
NoteFalse = nut(name:Name octave:4 sharp:true duration:1.0 instrument:none)

{Browse "NoteTrue into IsNote"}
{Browse {IsNote NoteTrue}}

