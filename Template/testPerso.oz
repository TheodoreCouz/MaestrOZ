\insert 'codeNew.oz'

% Concat
{Browse 'TEST: Concat'}
declare
A = [1 2 3]
B = [4 5 6]
{Browse {Concat A B}} % should print [1 2 3 4 5 6]

% TotalDuration
{Browse 'TEST: TotalDuration'}
declare
P = {PartitionToTimedList [c3 c3 c3 [c3 c4 c5]]}
%{Browse P}
{Browse {TotalDuration P}} % should print 4

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

% NoteToExtended
{Browse 'TEST: NoteToExtended'}
declare
Note = {NoteToExtended c3}
Note2 = {NoteToExtended Note}
{Browse Note} % should print "note(duration:1 instrument:none name:c octave:3 sharp:false)"
{Browse Note2} % should print "note(duration:1 instrument:none name:c octave:3 sharp:false)"


% ChordToExtended
{Browse 'TEST: ChordToExtended'}
declare 
Note = {NoteToExtended c3}
Chord = {ChordToExtended [c3 c3 c3]}
Chord2 = {ChordToExtended [c3 Note c3]}
{Browse Chord} % should print [note(duration:1 instrument:none name:c octave:3 sharp:false) ... 3 times]
{Browse Chord2} % should print [note(duration:1 instrument:none name:c octave:3 sharp:false) ... 3 times]

% PartitionToTimedList
{Browse 'TEST: PartitiontToTimedList'}
declare
Note = {NoteToExtended c3}
Chord = {ChordToExtended [c3 c3 c3]}
Flat = {PartitionToTimedList [Note Chord c4 [c4 Note]]}
{Browse Flat} % should print:
%   [note(duration:1 instrument:none name:c octave:3 sharp:false)
%   [note(duration:1 instrument:none name:c octave:3 sharp:false) ... 3 times]
%    note(duration:1 instrument:none name:c octave:4 sharp:false)
%   [note(duration:1 instrument:none name:c octave:4 sharp:false)
%   note(duration:1 instrument:none name:c octave:3 sharp:false]]
Transition = drone(duration:1)
{Browse {Label drone(duration:1)}}
{Browse {PartitionToTimedList [Transition]}}

% Drone Transition
{Browse 'TEST: Drone'}
declare
Note = {NoteToExtended c3}
Flat = {PartitionToTimedList [drone(note:c3 amount:2) c4 drone(note:[c5 c5 c5] amount:2)]}
{Browse Flat}

% Duration Transition
{Browse 'TEST: Duration'}
declare
Flat = {PartitionToTimedList [c1 c2]}
{Browse {Duration 12.0 Flat}} % each note should have a duration of 6 seconds

% Stretch Transition
{Browse 'TEST: Stretch'}
declare 
Flat = {PartitionToTimedList [c1 c2]}
{Browse {Stretch 0.5 Flat}} % each note should have a duration of 0.5 seconds

% Transpose Transistion
{Browse 'TEST: Transpose'}
declare
Flat = {PartitionToTimedList [c1 c2]}
{Browse {Transpose 3 Flat}}

declare
Note = {NoteToExtended c#3}
{Browse {NextNote ~12 note(duration:2 instrument:violon name:c octave:3 sharp:false)}}

