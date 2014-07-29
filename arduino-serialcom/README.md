##Stablish communication between the Arduino and Matlab##
This folder is for those people who wants to stablish a serial connection between the Arduino plataform and Matlab software under Linux/GNU.

###Verifying libraries###
When you connect your Arduino using Linux the most common port assigned to it is /dev/ttyACM0. Matlab can't recognize that, so you need to tell it.

1. Write $MATLABROOT under the Matlab command line
2. Write $ARCH under the Matlab command line
3. Create a java.opts file under the path $MATLABROOT/bin/$ARCH
4. Add the following line: -Dgnu.io.rxtx.SerialPorts=/dev/ttyS0:/dev/ttyUSB0:/dev/ttyACM0


