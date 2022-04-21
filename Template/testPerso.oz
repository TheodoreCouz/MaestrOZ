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

%RoundedDiv
declare 
A = ~14
B = 12
{Browse {RoundedDiv A B}} % should print 1

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
{Browse Flat} 

declare
Transition = [transpose(semitones:13 partition:[c1 c2])]
%{Browse Transition}
{Browse {PartitionToTimedList Transition}}

% Drone Transition
{Browse 'TEST: Drone'}
declare
Note = {NoteToExtended c3}
Flat = {PartitionToTimedList [drone(note:c3 amount:2) c4 drone(note:[c5 c5 c5] amount:2)]}
{Browse Flat}

% Duration Transition
{Browse 'TEST: Duration'}
{Browse {Duration 12.0 [c1 c2]}} % each note should have a duration of 6 seconds

% Stretch Transition
{Browse 'TEST: Stretch'}
declare 
{Browse {Stretch 0.5 [c1 c2]}} % each note should have a duration of 0.5 seconds
Flat2 = {Stretch 0.5 Flat}
{Browse {Stretch 3.0 Flat2}}


% Transpose Transistion
{Browse 'TEST: Transpose'}
declare
{Browse {Transpose 12 [c1 c2]}}

% NextNote
declare
Note = {NoteToExtended c#1}
{Browse {NextNote 123 Note}}

% NextChord
declare
Chord = {ChordToExtended [c1 c2 c3]}
%{Browse Chord}
{Browse {NextChord ~12 Chord}}

%%%%%%%%%%%%%%%%%%%% GLOBAL TEST FOR PARTITION TO TIMED LIST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
T1 = duration(seconds:3.0 partition:[c1 c1]) 
T2 = stretch(factor:2 partition [d2 d2])
T3 = drone(amount: 3 note:e3)
T4 = transpose(semitones:12 [f4])
{Browse {PartitionToTimedList [T2]}}
