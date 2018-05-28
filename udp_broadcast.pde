/**
 * udp_broadcast. Created by modifying the multicast example.
 *Lee Erickson
 * Date: 20180527
 * trying to broad cast to a TIVI Launchpad device
 * The TIVA device UDP port apears to be on 23. 
 * The ti file locator.c defines 
 // These defines are used to describe the device locator protocol.
 //
 //*****************************************************************************
 */

// #define TAG_CMD                 0xff
// #define TAG_STATUS              0xfe
// #define CMD_DISCOVER_TARGET     0x02

byte TAG_CMD = byte(0xFF);
byte TAG_STATUS = byte(0xFE);
byte CMD_DISCOVER_TARGET = byte(0x02);

String BROADCAST_IP_ADDRESS = "255.255.255.255";
String MULTICAST_IP_ADDRESS = "224.0.0.1";

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

  // to simplify the program, we use a byte[] array to pass the previous and
  // the current mouse coordinates. The PApplet size must be defined with 
  // values <=255
  size( 255, 255 );
  background( 128 );  // gray backround

// We can't seam to make a broadcast connection so we will setup a multicast.   
// create a broadcast connection on port 23
  //From Wikipedia: A special definition exists for the IP broadcast address 255.255.255.255. 
  //It is the broadcast address of the zero network or 0.0.0.0, which in Internet Protocol standards stands for this network,
  // i.e. the local network. Transmission to this address is limited by definition, in that it is never forwarded
  // by the routers connecting the local network to other networks.
  
  udp = new UDP( this, 23, MULTICAST_IP_ADDRESS );
  udp.broadcast(true);

  // Setup listen and wait constantly for incomming data
  udp.listen( true );

  // Turn on broad cast
  udp.broadcast(true);
  // ... well, just verifies if it's really a multicast socket and blablabla
  println( "init as Multicast socket ... " + udp.isMulticast() );
  println( "init as Broadcast socket ... " + udp.isBroadcast() );
  println( "UDP joins a group  ... "+udp.isJoined() );
  println( "UDP Broadcast on?  ... " + udp.broadcast(true) );
  
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

  // by default if the ip address and the port number are not specified, UDP 
  // send the message to the joined group address and the current socket port.
//  udp.send( data ); // = send( data, group_ip, port );
  udp.send( data, BROADCAST_IP_ADDRESS, 23  ); // = send( data, group_ip, port );

} // mouseMoved


/**
 * This is the program receive handler. To perform any action on datagram 
 * reception, you need to implement this method in your code. She will be 
 * automatically called by the UDP object each time he receive a nonnull 
 * message.
 */
void receive( byte[] data ) {

  // retrieve the mouse coordonates
  int x  = int( data[0] );
  int y  = int( data[1] );
  int px = int( data[2] );
  int py = int( data[3] );

  // slowly, clears the previous lines
  noStroke();
  fill( 0, 0, 0, 7 );
  rect( 0, 0, width, height);

  // and draw a single line with the given mouse positions
  stroke( 255 );
  line( x, y, px, py );
} // received


/**
 * on mouse click : 
 * send the TI UDP data on mouse click.
 */
 
void mouseClicked() {
  println ("Moused clicked");
//  return;
//byte TAG_CMD = byte(0xFF);
//byte TAG_STATUS = byte(0xFE);
//byte CMD_DISCOVER_TARGET = byte(0x02);


   // Tivia Locator UDP string
  byte[] bdata = new byte[4];
  //bdata[0] = {0xff, 0x04, 0x02, 0xff};
//  bdata[0] = byte(0xff);
  bdata[0] = TAG_CMD;
  bdata[1] = byte(0x04);
  bdata[2] = CMD_DISCOVER_TARGET;
  bdata[3] = byte(0xff);

  //String sLocator
  String sLocator = str(bdata[0] + bdata[1] + bdata[2] + bdata[3]);
  //println( "check sLocator string ASCII as ..." + sLocator.getBytes() );
  println( "Sending TI Locator Broadcast" );
  udp.send( bdata, BROADCAST_IP_ADDRESS, 23 ); // = send( data, group_ip, port );
}


