declare

% return a note identical to [Note] but with the next semitone
fun {NextSemiTone Note} Name Octave Sharp in
   if Note.sharp then
       Sharp = false
       Octave = Note.octave

       if Note.name == c then
           Name = d
       elseif Note.name == d then
           Name = e
       elseif Note.name == f then
           Name = g
       elseif Note.name == g then
           Name = a
       elseif Note.name == a then
           Name = b
       else skip
       end
   else
       if Note.name == e then 
           Name = f
           Sharp = false
           Octave = Note.octave
       elseif Note.name == b then 
           Name = c
           Octave = Note.octave + 1
           Sharp = false
       else 
           Name = Note.name
           Sharp = true
           Octave = Note.octave
       end
   end
   note(
       duration:(Note.duration) 
       instrument:(Note.instrument) 
       name:Name 
       octave:Octave 
       sharp:Sharp
       )
end
       

% return a note identical to [Note] but with the previous semitone
fun {PreviousSemiTone Note} Name Octave Sharp in
   if Note.sharp then
       Sharp = false
       Octave = Note.octave
       Name = Note.name
   else
       if Note.name == c then
           Name = b
           Sharp = false
           Octave = Note.octave - 1
       elseif Note.name == d then
           Name = c
           Sharp = true
           Octave = Note.octave
       elseif Note.name == e then %
           Name = d
           Sharp = true
           Octave = Note.octave
       elseif Note.name == f then
           Name = e
           Sharp = false
           Octave = Note.octave
       elseif Note.name == g then
           Name = f
           Sharp = true
           Octave = Note.octave
       elseif Note.name == a then
           Name = g
           Sharp = true
           Octave = Note.octave
       elseif Note.name == b then 
           Name = a
           Octave = Note.octave 
           Sharp = true
       else skip
       end
   end
   note(
       duration:(Note.duration) 
       instrument:(Note.instrument) 
       name:Name 
       octave:Octave 
       sharp:Sharp
       )
end

% transpose [Note] of 1 semitone higher (lower)
fun {TransposeNote N Note}
   if N > 0 then 
       {NextSemiTone Note}
   else
       {PreviousSemiTone Note}
   end
end

% transpose every note of [Chord] of 1 semitone higher (lower)
fun {TransposeChord N Chord}
   case Chord of H|T then
       {TransposeNote N H}|{TransposeChord N T}
   else nil
   end
end

% transposes every item of [Partition] of 1 semitone higher (lower)
fun {TransposeOnce N Partition} Dir in
   case Partition of H|T then
       if {Label H} == note then
           {TransposeNote N H}|{TransposeOnce N T}
       else
           {TransposeChord N H}|{TransposeOnce N T}
       end
   else nil
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Transpose [Partition] of [Semitones] semitones.
fun {TransposeAux SemiTones Dir Partition} Res Dir in
   if SemiTones == 0 then {TransposeOnce Dir Partition}
   else {TransposeAux SemiTones-1 Dir Partition}
   end
end

fun {Transpose SemiTones Partition} Dir in
   if SemiTones > 0 then Dir = 1 % high
   elseif SemiTones < 0 then Dir = ~1 % low
   end
   {TransposeAux {Abs SemiTones} Dir Partition}
end

%%%%%%%%%%%%%%TESTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%NextSemiTone
{Browse 'TEST: NextSemiTone'}
declare
Note = {NoteToExtended a#1}
{Browse {NextSemiTone {NextSemiTone Note}}}

%PreviousSemiTone
{Browse 'TEST: PreviousSemiTone'}
declare 
Note = {NoteToExtended f3}
{Browse {PreviousSemiTone Note}}

%TransposeNote
{Browse 'TEST: TransposeNote'}
declare
Note = {NoteToExtended c1}
{Browse {TransposeNote ~1 Note}}
{Browse {TransposeNote 1 Note}}

%TransposeChord
{Browse 'TEST: TransposeChord'}
declare 
Chord = {ChordToExtended [c1 c1]}
{Browse Chord}
{Browse {TransposeChord 1 Chord}} % transpose [Chord] high
{Browse {TransposeChord ~1 Chord}} % transpose [Chord] low

%TransposeOnce
{Browse 'TEST: TransposeOnce'}
declare
Flat = {PartitionToTimedList [c1 c2]}
{Browse {TransposeOnce ~1 Flat}} % should print [b0 b1]
{Browse {TransposeOnce 1 Flat}} % should print [c#1 c#2]

% Transpose Transistion
{Browse 'TEST: Transpose'}
declare
Flat = {PartitionToTimedList [c1 c2]}
{Browse {Transpose 3 Flat}}
