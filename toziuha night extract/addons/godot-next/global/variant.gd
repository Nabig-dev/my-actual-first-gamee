tool 
class_name Variant
extends Reference





static func var_to_string(p_value) -> String:
	if typeof(p_value) == TYPE_OBJECT and p_value.has_method("_to_string"):
		return p_value._to_string() as String
	return var2str(p_value)



static func get_type(p_value) -> String:
	match typeof(p_value):
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "bool"
		TYPE_INT:
			return "int"
		TYPE_REAL:
			
			
			return "float"
		TYPE_STRING:
			return "String"
		TYPE_VECTOR2:
			return "Vector2"
		TYPE_RECT2:
			return "Rect2"
		TYPE_VECTOR3:
			return "Vector3"
		TYPE_TRANSFORM2D:
			return "Transform2D"
		TYPE_PLANE:
			return "Plane"
		TYPE_QUAT:
			return "Quat"
		TYPE_AABB:
			return "AABB"
		TYPE_BASIS:
			return "Basis"
		TYPE_TRANSFORM:
			return "Transform"
		TYPE_COLOR:
			return "Color"
		TYPE_NODE_PATH:
			return "NodePath"
		TYPE_RID:
			return "RID"
		TYPE_OBJECT:
			var ct: = ClassType.new(p_value)
			return ct.get_type_class()
			
		TYPE_DICTIONARY:
			return "Dictionary"
		TYPE_ARRAY:
			return "Array"
		TYPE_RAW_ARRAY:
			return "PoolByteArray"
		TYPE_INT_ARRAY:
			return "PoolIntArray"
		TYPE_REAL_ARRAY:
			return "PoolRealArray"
		TYPE_STRING_ARRAY:
			return "PoolStringArray"
		TYPE_VECTOR2_ARRAY:
			return "PoolVector2Array"
		TYPE_VECTOR3_ARRAY:
			return "PoolVector3Array"
		TYPE_COLOR_ARRAY:
			return "PoolColorArray"
	return ""
