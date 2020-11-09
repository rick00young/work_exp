## sphinx study

1.启动搜索进程：

	/service/sphinx/bin/searchd -c sphinx.conf

2.生成索引：

 	../bin/indexer -c sphinx.conf company_name --rotate
 
 或
 
  	../bin/indexer -c sphinx.conf --rotate --all