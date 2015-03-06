var githubRoot = "https://github.com/craftyjs/Crafty/blob/develop/";


// var Router = ReactRouter;

// var DefaultRoute = Router.DefaultRoute;
// var Route = Router.Route;
// var RouteHandler = Router.RouteHandler;

var Outer = React.createClass({
  render: function() { 
    return <div className = "outerhandler"><RouteHandler/></div>
  }
})





// Assumes the marked.js renderer has been imported into a global variable `marked`
var MarkdownBlock = React.createClass({
  markedConfig: {
      renderer: (function() {
          var r = new marked.Renderer();
          r.code = function(code, language){
            return '<pre><code class="hljs ' + (language || "") + '">' + 
                hljs.highlight("javascript", code).value +
              '</code></pre>';
          };
          return r;
      })()
  },

  convert: function(raw) {
    var raw = marked(raw, this.markedConfig)
    return raw;
  },
  
  render: function() {
    var raw = this.props.value;
    var rawHtml = this.convert(raw);// marked(raw, {renderer:this.markedConfig});
    //console.log("REturned \n", rawHtml)
    var key = this.props.key;
    return <span key={key} className="markdown" dangerouslySetInnerHTML={{__html: rawHtml}} />
  }
})

function linkify(page, hash) {
  var name;
  if (hash)
    name = page + "#" + hash || ""; 
  else
    name = page || "";
  return name.replace(".", "-")
}

function createIndex(blocks) {
  var cats = {};
  var pages = {};
  var dictionary = {};
  function comp(c) {
    var clean = cleanName(c);
    return pages[clean] || (pages[clean] = {name:c, main: null, parts:[]})
  }
  function cat(c) {
    return cats[c] || (cats[c] = {name:c, pages:[]})
  }
  for (var i = 0; i < blocks.length; i++) {
    var block = blocks[i];
    // Add to any categories
    if (block.categories) {
      for (var j = 0; j < block.categories.length; j++) {
        if (block.name) {
          cat(block.categories[j]).pages.push(block.name)
          
        }
        comp(block.name).main = block;
        block.linkID = linkify(block.comp);

      }
    }
    // Add to any comps
    if (block.comp && block.name) {
      comp(block.comp).parts.push(block);
      block.linkID = linkify(block.comp, block.name);
    }

    if (block.name) {
      dictionary[block.name] = block;
    }
  }

  console.log("Cats", cats)
  return {
    pages: pages,
    categories: cats,
    dictionary: dictionary
  }

}


var ToC = React.createClass({
  render: function() {
    var blocks = this.props.data;
    var toc = createIndex(blocks);
    var primary = this.props.primary;
    // Generate categories
    catArray = [];
    for (var cat in toc.categories) {
      if (cat != primary) {
        catArray.push(toc.categories[cat]);
      }
    }
    catArray.sort(nameSort);
    var catElements = catArray.map( function(cat, index){return <Category key={cat.name} catName = {cat.name} pages = {cat.pages}/>});
    return (
      <div className = "category-list">
        <Category catName = {primary} pages = {toc.categories[primary].pages}/>
        {catElements}
      </div>
    )
  }

})

function cleanName(raw) {
  return raw.replace(" ", "-")
}

var DocLink = React.createClass({
  render: function() {
    var cleanTarget = cleanName(this.props.target);
    return <a href={"#page/" + cleanTarget}>{this.props.target}</a>
  }
})

var Category = React.createClass({
  render: function() {
    this.props.pages.sort(stringSort);
    var pages = this.props.pages.map(function(page, index){return <li key={page}><DocLink target={page}/></li>});
    return ( 
      <div className="category">
        <h4>{this.props.catName}</h4>
        <ul className="category-list">
          {pages}
        </ul>
      </div>
    )
  }
})

function createNode(node, index) {
  switch(node.type) {
    case "method":
      return <Method key={index} data={node}/>
    case "param":
      return <Parameter key={index} paramName={node.name} paramDescription={node.description} />
    case "triggers":
      return <Events key={index} triggers={node.events}/>
    case "raw":
      return <MarkdownBlock value={node.value} key={index} />
    case "return":
      return <Returns key={index} value={node.value}/>
    case "xref":
      return <SeeAlso key={index} xrefs = {node.xrefs} />
    case "example":
      return <Example key={index} contents={node.contents} />
    default:
      return <p key={index} > Unsupported node type: <b style={{color:"red"}}>{node.type}</b></p>
  }
}


var SubSectionHeader = React.createClass({
  render: function() {
    return <h4>{this.props.children || ""}</h4>
  }
})

// SeeAlso
var SeeAlso = React.createClass({
  render: function() {
    xrefs = this.props.xrefs.map(function(xref, index){
      return <li key={xref}><DocLink target={xref} /></li>
    });
    return <div>
      <SubSectionHeader>See Also</SubSectionHeader>
      <ul>
        {xrefs}
      </ul>

    </div>
  }
})

// Example

var Example = React.createClass({
  render: function() {
    var contents = this.props.contents;
    var pieces = contents.map(createNode);
    return (<div className = "example">
      <SubSectionHeader>Example</SubSectionHeader>
      {pieces}
    </div>)

  }
})

// Event & Trigger

var Events = React.createClass({
  render: function() {
    triggers = this.props.triggers.map(function(trigger, incex){
      return <Trigger trigger = {trigger}/>
    })
    return (
      <div className="triggered-events">
        <SubSectionHeader>Events</SubSectionHeader>
        <div className = "trigger-list">
          {triggers}
        </div>
      </div>
    );
  }
})

var Trigger = React.createClass({
  render: function() {
    var trigger = this.props.trigger;
    var triggerData;
    if (trigger.objName!=="Data" || trigger.objProp)
      triggerData = <span className="trigger-data">[ {trigger.objName} {trigger.objProp ? "{" + trigger.objProp + "}": ""}]</span>
    else
      triggerData = "";
    return (
      <dl className="trigger">
          <dt>{trigger.event} {triggerData}</dt>
          <dd>{trigger.description}</dd>
      </dl>
    )

  }
})


// Objects for displaying methods: Method is the container, Signature is required, Parameter and Returns are optional

var Method = React.createClass({
  render: function() {
    var contents = this.props.data.contents;
    var pieces = contents.map(createNode);
    return (
      <div className="crafty-method">
        <Signature  sign = {this.props.data.signature} />
        {pieces}
      </div>
    )
  }
});

var Parameter = React.createClass({
  render: function() {
    return (
      <dl className = "parameter">
        <dt> {this.props.paramName} </dt>
        <dd><MarkdownBlock value={this.props.paramDescription} key={1} /></dd>
      </dl>
    )
  }
})

var Signature = React.createClass({
  render: function() {
    return (
        <code className="signature">{this.props.sign}</code>
    )
  }
})

var Returns = React.createClass({
  render: function() {
       return (
      <dl className = "parameter returns"> 
        <dt className="returns"> [Returns] </dt> 
        <dd><MarkdownBlock value={this.props.value} key={2} /></dd> 
      </dl>
    )
  }
})


// Base doclet component

var Doclet = React.createClass({
  render: function() {
    var contents = this.props.data.contents;
    var pieces = contents.map(createNode)
    if (!this.props.top) {
      var link = <a href='#doc-nav' className='doc-top'>Back to top</a>
      var header = <h2 className="doclet-header">{this.props.data.name}{link}</h2>
    } else {
      var header = "";
    }
    return (
      <div id={this.props.data.name}>
        {header}
        <span className="doc-source"><a href={githubRoot + this.props.data.file+"#L" + this.props.data.startLine}>{this.props.data.file+"#"+this.props.data.startLine}</a></span>
        {pieces}
      </div>
    )
  }
});



function nameSort(a, b) {
    return stringSort(a.name, b.name);
}

function stringSort(a, b) {
    if (typeof a === "string" && typeof b==="string")
      return a.toUpperCase().localeCompare(b.toUpperCase());
    else
      if (typeof b === "string")
        return 1;
      else
        return -1;
}


// page, dict, 
var DocPage = React.createClass({
  render: function() {
    var page = this.props.page;
    var parts = page.parts;
    parts.sort(nameSort);
    var partlets = parts.map(function(part, index){return <Doclet data={part} top={false}/>});
    var page_toc = parts.map( function(part, index){ return <li><InternalLink target={part.name} value={part.name}/></li>});
    //console.log(parts);
    if (!page.main){
      return <div/>
    }
    if (parts.length > 0) {
      var bottomParts = 
        <div>
          <SubSectionHeader>Methods and Properties</SubSectionHeader>
          <ul className = "page-toc">
            {page_toc}
          </ul>
          {partlets}
        </div>
    } else {
      var bottomParts = "";
    }
    return (
      <div className="doc-page">
        <h1>{page.main.name}</h1>
        <Doclet data={page.main} top={true}/>
        {bottomParts}
      </div>
    )
  }
})

var API = React.createClass({
  getInitialState: function() {
    return {data: [], selector: "Crafty.canvasLayer", index:{categories:[], pages:[], dictionary:[]}};  
  },
  componentDidMount: function() {

    $.ajax({
      url: "testDoc.json", //this.props.url,
      dataType: 'json',
      success: function(data) {
        console.log("Setting state");
        var index = createIndex(data);
        this.setState({data: data, index:index, selector: "Crafty.canvasLayer"});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });


  },
  setPage: function(name) {
    this.setState({selector:name})
  },
  render: function() {
    return <div>

    </div>
    var pages = this.state.index.pages;
    var selector = this.state.selector;
    var dict = this.state.index.dictionary;
    
    var pageId = this.getParams().pageId;
    var page = pageId || pages[selector];
    if (!page)  return <div/>
    return <div className="row">
      <div className="toc-holder">
        <ToC data = {this.state.data} primary = "Core"/>
      </div>
      <div className="doc-page-holder">
        <DocPage page={page} dict={dict}/>
      </div>
    </div>
  }
})


var OnePage = React.createClass({
  mixins: [Router.State],
  getInitialState: function() {
    return {data: [], selector: "Crafty.canvasLayer", index:{categories:[], pages:[], dictionary:[]}};  
  },
  componentDidMount: function() {

    $.ajax({
      url: "testDoc.json", //this.props.url,
      dataType: 'json',
      success: function(data) {
        console.log("Setting state");
        var index = createIndex(data);
        this.setState({data: data, index:index, selector: "Crafty.canvasLayer"});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });

    // Set the router from in here!
    var setState = this.setState.bind(this);
    var router = Router({
       '/page/:pageId': function(pageId){
          setState({selector:pageId});
        }
    });
    router.init('/');

  },
  setPage: function(name) {
    this.setState({selector:name})
  },
  render: function() {
    // return <div>THINGY: {this.props.testProp}</div>
    var pages = this.state.index.pages;
    var selector = this.state.selector;
    var dict = this.state.index.dictionary;
    
    //var pageId = this.getParams().pageId;
    var page = pages[selector];
    if (!page)  return <div/>
    return <div className="row">
      <div className="toc-holder">
        <ToC data = {this.state.data} primary = "Core"/>
      </div>
      <div className="doc-page-holder">
        <DocPage page={page} dict={dict}/>
      </div>
    </div>
  }
});


var InternalLink = React.createClass({
  render: function() {
    var target = this.props.target;
    scroll = function() {
      document.getElementById(target).scrollIntoView(true);
    }
    return <a onClick={scroll}>{this.props.value}</a>
  }
})

// var routes =( 
//     <Route handler={Outer} path="/"> 
//       <Route handler={OnePage} path="/page/:pageId"/>
//       <DefaultRoute handler={OnePage}/>

//     </Route>
// );

// Router.run(routes, function (Handler) {
//   React.render(<Handler/>, document.body);
// });

React.render(
  <OnePage url="testDoc.json" />,
  document.getElementById('content')
);

