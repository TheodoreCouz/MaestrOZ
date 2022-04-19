\insert 'codeNew.oz'

% Concat
declare
A = [1 2 3]
B = [4 5 6]
{Browse {Concat A B}} % should print [1 2 3 4 5 6]

% NoteToExtended
declare
Note = {NoteToExtended c3}
Note2 = {NoteToExtended Note}
{Browse Note} % should print "note(duration:1 instrument:none name:c octave:3 sharp:false)"
{Browse Note2} % should print "note(duration:1 instrument:none name:c octave:3 sharp:false)"


% ChordToExtended
declare 
Note = {NoteToExtended c3}
Chord = {ChordToExtended [c3 c3 c3]}
Chord2 = {ChordToExtended [c3 Note c3]}
{Browse Chord} % should print [note(duration:1 instrument:none name:c octave:3 sharp:false) ... 3 times]
{Browse Chord2} % should print [note(duration:1 instrument:none name:c octave:3 sharp:false) ... 3 times]

% PartitionToTimedList
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
declare
Note = {NoteToExtended c3}
Flat = {PartitionToTimedList [drone(note:c3 amount:2) c4 drone(note:[c5 c5 c5] amount:2)]}
{Browse Flat}


