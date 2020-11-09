## grunt study

###
	
	npm init

### install grunt

	npm install grunt --save-dev
	
	
### install plugin

	npm install --save-dev grunt-contrib-concat grunt-contrib-jshint grunt-contrib-sass grunt-contrib-uglify grunt-contrib-watch grunt-contrib-connect
	
	npm install grunt-contrib-cssmin --save-dev
	npm install grunt-concat-css --save-dev
	npm install grunt-contrib-sass --save-dev
	
### Gruntfile.js example

```javascript
module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    concat: {
      options: {
        separator: ';'
      },
      dist: {
        src: ['src/**/*.js'],
        dest: 'dist/<%= pkg.name %>.js'
      },
      foo: {
	      files: {
	        'dest/a.js': ['src/aa.js', 'src/aaa.js'],
	        'dest/a1.js': ['src/aa1.js', 'src/aaa1.js'],
	      },
    },    },
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy") %> */\n'
      },
      dist: {
        files: {
          'dist/<%= pkg.name %>.min.js': ['<%= concat.dist.dest %>']
        }
      }
    },
    //qunit: {
    //  files: ['test/**/*.html']
    //},
    jshint: {
      files: ['Gruntfile.js', 'src/**/*.js', 'test/**/*.js'],
      options: {
        //这里是覆盖JSHint默认配置的选项
        globals: {
          jQuery: true,
          console: true,
          module: true,
          document: true
        }
      }
    }
    /*,
    watch: {
      files: ['<%= jshint.files %>'],
      tasks: ['jshint', 'qunit']
    }*/
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-qunit');
  //grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-concat');

  //grunt.registerTask('test', ['jshint', 'qunit']);
  grunt.registerTask('test', ['jshint']);

  grunt.registerTask('default', ['jshint', 'concat', 'uglify']);

};

```


## Q&A

### 1.Q:The package grunt@1.0.1 does not satisfy its siblings' peerDependencies requirements!

A:解决方案：

	1.删除grunt及其扩展，然后调换顺序重新安装。

