class Stage {
  Transfer currentTransfer = null;
  Stage() {
  }
  
  Transfer getCurrentTransfer() {
    return currentTransfer;
  }
  
  void setCurrentTransfer(Transfer transfer) {
    currentTransfer = transfer;
  }
}

Stage stage = new Stage();

int nodeCount;
Node[] nodes = new Node[100];
HashMap nodeTable = new HashMap();

int edgeCount;
Edge[] edges = new Edge[500];

TmpEdge tmpEdge;
Node tmpNode;

static final color nodeColor   = #F0C070;
static final color selectColor = #FF3030;
static final color fixedColor  = #FF8080;
static final color edgeColor   = #000000;

static final int EXCHANGE = 0;
static final int QUEUE = 1;
static final int PRODUCER = 2;
static final int CONSUMER = 3;

static final int SOURCE = 0;
static final int DESTINATION = 1;

color[] colors = new color[20];

PFont font;

void setup() {
  size(600, 600);
  font = createFont("SansSerif", 10);
  textFont(font);
  smooth();
  
  colors[EXCHANGE] = #FF8408;
  colors[QUEUE] = #0816FF;
  colors[PRODUCER] = #3F4031;
  colors[CONSUMER] = #E1FF08;
  
  
  // addNode("exchange");
  // addNode("queue");
  // addNodeByType(EXCHANGE, "my-exchange", random(width), random(height));
  // addNodeByType(QUEUE, "my-queue", random(width), random(height));
  // addNodeByType(PRODUCER, "my-producer", random(width), random(height));
  // addNodeByType(CONSUMER, "my-consumer", random(width), random(height));
  
  buildToolbar();
}

void buildToolbar() {
  addToolbarItem(EXCHANGE, "exchange", 30, 20);
  addToolbarItem(QUEUE, "queue", 30, 50);
  addToolbarItem(PRODUCER, "producer", 30, 80);
  addToolbarItem(CONSUMER, "consumer", 30, 110);
}

ToolbarItem[] toolbarItems = new ToolbarItem[20];
int toolbarItemsCount;

ToolbarItem addToolbarItem(int type, String label, float x, float y) {
  ToolbarItem t = new ToolbarItem(type, label, x, y);
  toolbarItems[toolbarItemsCount++] = t;
  return t;
}
  

//void addEdgeFromLabels(String fromLabel, String toLabel) {
//  Node from = findNode(fromLabel);
//  Node to = findNode(toLabel);
//  
//  addEdge(from, to);
//}

boolean addEdge(Node from, Node to) {
  for (int i = 0; i < edgeCount; i++) {
    if ((edges[i].from == from && edges[i].to == to) ||
        (edges[i].to == from && edges[i].from == to)) {
      return false;
    }
  }
  
  Edge e = new Edge(from, to, edgeColor);
  if (edgeCount == edges.length) {
    edges = (Edge[]) expand(edges);
  }
  edges[edgeCount++] = e;
  return true;
}

//Node findNode(String label) {
//  label = label.toLowerCase();
//  Node n = (Node) nodeTable.get(label);
//  if (n == null) {
//    return addNode(label);
//  }
//  return n;
//}

Node newNodeByType(int type, String label, float x, float y) {
  Node n = null;
  switch (type) {
    case EXCHANGE:
      n = new Exchange(label, x, y);
      break;
    case QUEUE:
      n = new Queue(label, x, y);
      break;
    case PRODUCER:
      n = new Producer(label, x, y);
      break;
    case CONSUMER:
      n = new Consumer(label, x, y);
      break;
    default:
      println("Unknown type");
      break;
  }
  return n;
}

Node addNodeByType(int type, String label, float x, float y) {
  Node n = newNodeByType(type, label, x, y);
  
  if (n != null) {
      if (nodeCount == nodes.length) {
        nodes = (Node[]) expand(nodes);
      }
  
      nodeTable.put(label, n);
      nodes[nodeCount++] = n;
  }
  
  return n;
}

//Node addNode(String label) {
//  Node n = new Node(label, nodeColor);  
//  if (nodeCount == nodes.length) {
//    nodes = (Node[]) expand(nodes);
//  }
//  nodeTable.put(label, n);
//  nodes[nodeCount++] = n;  
//  return n;
//}

void draw() {
  background(255);
  
  for (int i = 0; i < toolbarItemsCount ; i++) {
    toolbarItems[i].draw();
  }
  
  for (int i = 0 ; i < edgeCount ; i++) {
    edges[i].draw();
  }
  
  for (int i = 0 ; i < nodeCount ; i++) {
    nodes[i].draw();
  }
  
  if (tmpEdge != null) {
    tmpEdge.draw();
  }
  
  if (tmpNode != null) {
    tmpNode.draw();
  }
  
  if (stage.getCurrentTransfer() != null) {
    stage.getCurrentTransfer().update();
    stage.getCurrentTransfer().draw();
  }
}

Node from;
Node to;

Node nodeBelowMouse() {

  for (int i = 0; i < nodeCount; i++) {
    Node n = nodes[i];    
    if (n.isBelowMouse()) {
      return n;
    }
  }
  
  return null;
}

void mousePressed() {
  from = nodeBelowMouse();
  
  if (from != null && altKeyPressed() && from.canStartConnection()) {
    println("adding tmpEdge"); 
    tmpEdge = new TmpEdge(from, mouseX, mouseY, edgeColor);
  }
}

boolean altKeyPressed() {
  return keyPressed && key == CODED && keyCode == ALT;
}

void mouseDragged() {
  if (from != null) {
    if (tmpEdge != null) {
      tmpEdge.mouseDragged();
    } else {
      from.mouseDragged();
    }
  }
  
  for (int i = 0; i < toolbarItemsCount ; i++) {
    toolbarItems[i].mouseDragged();
  }
  
  if (tmpNode != null) {
    tmpNode.mouseDragged();
  }
}

boolean validNodes(Node from, Node to, TmpEdge tmpEdge) {
  return to != null && from != null && tmpEdge != null && to != from; 
}

void mouseReleased() {
  if (tmpNode != null) {
    addNodeByType(tmpNode.getType(), tmpNode.getLabel(), tmpNode.getX(), tmpNode.getY());
  }
  
  
  // if we have a an edge below us we need to make the connection
  to = nodeBelowMouse();
  
  // Logic to make a connection between Nodes
  if (validNodes(from, to, tmpEdge) && to.accepts(from)) {
    println("after valid nodes");
    if (addEdge(from, to)) {
      from.connectWith(to, DESTINATION);
      to.connectWith(from, SOURCE);
      println("addEdge true");
    } else {
       println("addEdge false");
    }
  }
  
  if (edgeCount > 0) {
    // get firts edge and animate circle along it.
    // stage.setCurrentTransfer(new Transfer(stage, edges[0]));
  }
  
  from = null;
  to = null;
  tmpEdge = null;
  tmpNode = null;
}
