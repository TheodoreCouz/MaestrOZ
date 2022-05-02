
fun {FadeHelper Music Index CountOfStep StartDuration StopDuration Length ValueStepStart ValueStepStop}
      local StopStartsHere in
      StopStartsHere=Length-StopDuration 
      if CountOfStep >= StopStartsHere then 
         case Music of H|T then %cas fade de fin
            H*Index |{FadeHelper T Index-ValueStepStop CountOfStep+1.0 StartDuration StopDuration Length ValueStepStart ValueStepStop }
         else
            nil
         end
      else
         case Music of H|T then
            if CountOfStep < StartDuration then %cas fade de début
               H*Index| {FadeHelper T Index+ValueStepStart CountOfStep+1.0 StartDuration StopDuration Length ValueStepStart ValueStepStop }
            else    %cas entre les 2 fades 
               H |{FadeHelper T 1.0-ValueStepStop CountOfStep+1.0 StartDuration StopDuration Length ValueStepStart ValueStepStop }
            end
         else
            nil 
         end
      end
      end 
   end

   fun {Fade Music Start Stop }
      local StartDuration StopDuration Length ValueStepStart ValueStepStop in 

         StartDuration=Start*44100.0
         StopDuration=Stop*44100.0
         
         Length={IntToFloat {List.length Music}}

         ValueStepStart=1.0/StartDuration
         ValueStepStop=1.0/StopDuration

         {FadeHelper Music 0.0 0.0 StartDuration StopDuration Length ValueStepStart ValueStepStop }
      end 
   end