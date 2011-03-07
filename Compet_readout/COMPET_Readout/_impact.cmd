setMode -bs
setMode -bs
setCable -port auto
Identify 
identifyMPM 
assignFile -p 1 -file "Z:/compet_readout/compet_readout/COMPET_Readout/top.bit"
Program -p 1 
setMode -bs
deleteDevice -position 1
