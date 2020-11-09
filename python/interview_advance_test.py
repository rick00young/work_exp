# 每一题
def flatJson(data=None):
	"""
	input = { "a": 1, "b": { "c": 2, "d": [3,4] } }
	output = o = {"a": 1, "b.c": 2, "b.d": [3,4] }
	:param data:
	:return:
	"""
	if not data:
		return {}
	output = {}
	mergeKey(data=data, key_list=[], output=output)
	# del data
	return output


def mergeKey(data=None, key_list=None, output=None):
	if not data:
		return {}
	for key in data:
		value = data.get(key, '')
		if key_list:
			_key_list = key_list.copy()
			_key_list.append(key)
		else:
			_key_list = [key]

		if 'dict' == type(value).__name__:
			_key = mergeKey(value, key_list=_key_list, output=output)
			if _key:
				_key_list.append(_key)
			return key
		else:
			output['.'.join(_key_list)] = value


## 第二题
def store(data=None):
	"""
	input = a[0]["key1"]="value1"
			a[0]["key2"]="value2"
			a[1]["keyA"]="valueA"
	output = text="key1=value1;key2=value2\nkeyA=valueA\n..."

	:param data:
	:return:
	"""
	if not data:
		return []
	output = []
	for item in data:
		if not item:
			continue
		text = ['%s=%s' % (key, item.get(key, '')) for key in item]
		output.append(';'.join(text))
	return '\n'.join(output)


def load(text=None):
	if not text:
		return []
	output = []
	item_list = text.split('\n')
	for item in item_list:
		value = item.split(';')
		v_dict = {}
		for v in value:
			v_list = v.split('=')
			if len(v_list) < 2:
				continue
			v_dict[v_list[0]] = v_list[1]
		output.append(v_dict)

	return output


## 第三题
'''
	A:  index:0 weight:1
	B:  index:1 weight:2
	C:  index:2 weight:2

	思路:
		将节点权重转化为节点之间的边的权重:
			1.据题意,两个节点之间的边权重值取两个节点权重值较大着.
			2.虚拟一个起点,其权重为0.
		如果所给图是有向有环图,那么将不存在最长路径,因为路径一直在循环,最长路径将无穷大.
		所以在构造图时要先检查是否有环.



'''
import numpy as np

MATRIX = []
VERTEX = []
EDGES = []
INDEGREE = []
TOPO = []


def createGraph(vertex=None, path=None):
	"""
	创建图,邻接矩阵
	vertex = {'start': (0, 0),'A': (1, 1), 'B': (2, 2), 'C': (3, 2)}
	path = {'start': ['A', 'B', 'C'], 'A': ['B', 'C'], 'B': ['C']}
	:param data:
	:return:
	"""
	for i in vertex:
		VERTEX.append('')
		INDEGREE.append(0)
		TOPO.append(0)
		EDGES.append([0 for _ in range(len(vertex))])

	# edges = []
	edges_set = set()
	for k in path:
		p = path.get(k, [])
		if not p:
			continue
		for v in p:
			start_node = vertex.get(k)
			end_node = vertex.get(v)
			s = start_node[0]
			e = end_node[0]

			_k = '%s-%s' % (max(s, e), min(s, e))
			if _k in edges_set:
				raise Exception('此条边重复了,可以会出现环, %s-%s' % (s, e))
			edges_set.add(_k)

			VERTEX[s] = k
			VERTEX[e] = v
			w = max(start_node[1], end_node[1])
			# edges.append([k, v, w])
			EDGES[s][e] = w
			# print('%s-%s-%s' % (start_node[0], end_node[0],w))

	# print(edges)
	# print(EDGES)
	# print(VERTEX)

def getNextVertex(in_source_set):
	length = EDGES
	for i in range(len(EDGES)):
		if in_source_set[i]:
			continue
		found = True
		for j in range(len(EDGES)):
			if in_source_set[j]:
				continue
			if j == i:
				continue
			if length[j][i] > 0:
				found = False
		if found:
			return i
	return -1

def longestPath():
	in_source_set = [False for _ in range(len(EDGES))]
	in_source_set[0] = True

	max_length = [0 for _ in range(len(EDGES))]
	max_path = ['' for _ in range(len(EDGES))]
	for j in range(1, len(EDGES)):
		cur_vex = getNextVertex(in_source_set)
		if -1 == cur_vex:
			continue
		# print(cur_vex)
		cur_max_len = 0
		pre_vex = 0
		for i in range(len(EDGES)):
			if not in_source_set[i]:
				continue
			if EDGES[i][cur_vex] > 0 and cur_max_len < max_length[i] + EDGES[i][cur_vex]:
				cur_max_len = max_length[i] + EDGES[i][cur_vex]
				pre_vex = i
		max_length[cur_vex] = cur_max_len
		in_source_set[cur_vex] = True
		max_path[cur_vex] = str(max_path[pre_vex])
		max_path[cur_vex] += '%d->' % (pre_vex)

		cur_max_len = 0

	for i in range(len(EDGES)):
		print("Max Length to ", i, ': ', max_length[i], '\tPath: ', '%s%s' % (max_path[i], i))
		# print('\tPath :')
		# print(max_path[i], i)

	return max_length[len(EDGES) -1]


if '__main__' == __name__:
	print('*'*10,'第一题', '*'*10)
	_input = {"a": 1, "b": {"c": 2, "d": [3, 4], "e": {"f": 5}}}
	# print('_input:')
	print('json:', _input)
	# output = {}
	_output = flatJson(data=_input)
	#
	# print('_output')
	print('flatJson:', _output)

	print('*'*10, '第二题', '*'*10)
	a = [
		{'key1': 'value1', 'key2': 'value2'},
		{'keyA': 'valueA'}
	]
	print('array:', a)
	output = store(a)
	print('store_data:')
	print(output)
	json_list = load(output)
	print('load_data:', json_list)

	print('*'*10, '第三题', '*'*10)
	vertex = {'start': (0, 0), 'A': (1, 1), 'B': (2, 2), 'C': (3, 2)}
	path = {'start': ['A', 'B', 'C'], 'A': ['B', 'C'], 'B': ['C']}
	# path = {'start': ['A', 'B', 'C'], 'A': ['B', 'C'], 'B': ['C', 'A']} # 此图有环
	print('vertex:', vertex)
	print('path:', path)
	edges = createGraph(vertex=vertex, path=path)
	# print(edges)
	# print(VERTEX)
	# print(np.array(EDGES))
	# print(len(EDGES))
	l = longestPath()

