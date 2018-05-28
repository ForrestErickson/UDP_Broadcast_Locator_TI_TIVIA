/**
 * udp_broadcast. Created by modifying the Proccessing udp_multicast example.
 *Lee Erickson
 * Date: 20180527
 * Trying to broad cast to a TIVI Launchpad device
 * The TIVA device UDP port apears to be on 23. 
 * The ti file locator.c defines a sequence of four bytes it wants to receive. 
 * These defines are used to describe the device locator protocol.
 #define TAG_CMD                 0xff
 #define TAG_STATUS              0xfe
 #define CMD_DISCOVER_TARGET     0x02
 */

// TAG_CHECK_BYTE formula as per locator.c in LocatorReceive function.
byte TAG_CMD = byte(0xFF);
byte TAG_STATUS = byte(0xFE);
byte CMD_DISCOVER_TARGET = byte(0x02);
byte TAG_CHECK_BYTE = byte((0 - TAG_CMD - 4 - CMD_DISCOVER_TARGET) & 0xff);

// IP addresses and UDP port numbers.
String BROADCAST_IP_ADDRESS = "255.255.255.255";
String MULTICAST_IP_ADDRESS = "224.0.0.1";
String MY_IP_ADDRESS = "192.168.1.29";
int UDP_PORT = 23;

 /*
 //for the UDP payload .
 * (./) udp_multicast.pde - how to use UDP library as multicast connection
 * (cc) 2006, Cousot stephane for The Atelier Hypermedia
 * (->) http://hypermedia.loeil.org/processing/
 *
 * Pass the mouse coordinates over the network to draw an "multi-user picture".
 *
 * --
 *
 * about multicasting:
 * The only difference between unicast/broadcast and multicast address is that 
 * all interfaces identified by that address receive the same data. Multicasting
 * provide additional options in the UDP object (see the documentation for 
 * more informations), but the usage is commonly the same: simply add the 
 * multicast group address in his initialization to reflect a multicast 
 * connection.
 *
 * (note: currently applets are not allowed to use multicast sockets)
 */

// import UDP library
import hypermedia.net.*;

UDP udp;  // the UDP object

/**
 * init the frame and the UDP object.
 */
void setup() {
  size( 255, 255 );
  //background( 128 );  // gray backround
  background( 32 );  // dark gray backround

// Setup Broadcast by setting up multicast ????
  udp = new UDP( this, UDP_PORT, MULTICAST_IP_ADDRESS );
  udp.log(true);  //Wonder what?
  udp.broadcast(true);

  // Setup listen and wait constantly for incomming data
  udp.listen( true );
  
  if(udp.isListening()) {
    println("We are listening");
  }
  
//  udp.setReceiveHandler(myCustomReceiveHandler());
//  udp.setReceiveHandler(name);

  // Turn on broadcast
  udp.broadcast(true);
  // ... well, just verifies if it's really a multicast socket and blablabla
  println( "init as Multicast socket ... " + udp.isMulticast() );
  println( "init as Broadcast socket ... " + udp.isBroadcast() );
  println( "UDP joins a group  ... "+udp.isJoined() );
//  println( "UDP Broadcast on?  ... " + udp.broadcast() );
  
// Get local IP address
//  String myIPaddress = udp.address();
//  println("My IP address is: " + myIPaddress);
  
}

// process events
void draw() {
}


/**
 * on mouse move : 
 * send the mouse positions over the network on UDP broad cast.
 */

void mouseMoved() {

  byte[] data = new byte[4];	// the data to be send
  // add the mouse positions
  data[0] = byte(mouseX);
  data[1] = byte(mouseY);
  data[2] = byte(pmouseX);
  data[3] = byte(pmouseY);
//  udp.send( data, BROADCAST_IP_ADDRESS, UDP_PORT  ); // = send( data, group_ip, port );
} // mouseMoved

/**
 * on mouse click : 
 * send the TI UDP data on mouse click.
 */
 
void mouseClicked() {
  println ("Moused clicked");

 // Tivia Locator UDP string creation.
 // This works with the full Launchpad conditional test   
  byte[] bdata = new byte[255];
  bdata[0] = TAG_CMD;
  bdata[1] = byte(0x04);
  bdata[2] = CMD_DISCOVER_TARGET;
  bdata[3] = byte(TAG_CHECK_BYTE);

  //String sLocator
  String sLocator = str(bdata[0] + bdata[1] + bdata[2] + bdata[3]);
  println( "Sending TI Locator Broadcast" );
  udp.send( bdata, BROADCAST_IP_ADDRESS, UDP_PORT ); // = send( data, group_ip, port );
} // mouseClicked

/**
 * This is the program receive handler. To perform any action on datagram 
 * reception, you need to implement this method in your code. She will be 
 * automatically called by the UDP object each time he receive a nonnull 
 * message.
 */
void receive( byte[] data ) {
  print("Received data: ");
//  byte mydata[] = data;
//  int mydatalength = udp.getBuffer();

//Write some text to the drawing window.
  textSize(32);  
  text("Got: ", 0,20);
  for (int i=0; i<255; i++)
  {
  text(char(data[i]), i*32 ,41);  
  print(hex(data[i]));
  }
  println(" ");
} // received

/*
//From the UDP library
//   void myCustomReceiveHandler(byte[] message, String ip, int port) {
//   void myCustomReceiveHandler(byte[] data[], MY_IP_ADDRESS, UDP_PORT) {
   void myCustomReceiveHandler(data[], MY_IP_ADDRESS, UDP_PORT) {
  // do something here...
    textSize(32);  
  text("Got: ", 0,20);
  for (int i=0; i<255; i++)
  {
  text(char(data[i]), i*32 ,41);  
  print(hex(data[i]));
 }// myCustomReceiveHandler
*/

