numbers = [4, 2, 4, 7, 2, 4, 9, 2, 4, 7, 7, 154,154, 154, 154]
s = set(numbers)
k = list()
v = list()
kv = list()
final_list = list()
for a in s:
    k.append(a)
    v.append(numbers.count(a))

kv = list(item for item in zip(k,v))
print(kv)

big_num = max(kv[1])
# print(big_num)

for item in kv:
    if item[1] == big_num:
        final_list.append(item)
print(final_list)