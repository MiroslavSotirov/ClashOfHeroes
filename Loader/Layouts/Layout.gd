extends Resource
class_name Layout

export(Vector2) var viewport = Vector2.ZERO;
export(String) var name = "";
export(float) var threshold = 0;
# the threshold of the next layout, it is used if the element positions are calculated dynamically,
# i.e. on "resize", not on "layoutchange"
export(float) var thresholdEnd = 0;
export(float) var max_zoom = 1;
