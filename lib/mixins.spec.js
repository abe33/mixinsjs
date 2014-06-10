(function() {
  var mixins,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if (typeof module === 'undefined') {
    mixins = window.mixins;
  } else {
    global.mixins = mixins = require('../../lib/mixins');
  }

  xdescribe(mixins.Aliasable, function() {
    given('testClass', function() {
      var TestClass;
      return TestClass = (function() {
        function TestClass() {}

        TestClass.extend(mixins.Aliasable);

        TestClass.prototype.foo = function() {
          return 'foo';
        };

        TestClass.getter('bar', function() {
          return 'bar';
        });

        TestClass.alias('foo', 'oof', 'ofo');

        TestClass.alias('bar', 'rab', 'bra');

        return TestClass;

      })();
    });
    subject('instance', function() {
      return new this.testClass;
    });
    its('oof', function() {
      return should(equal(this.instance.foo));
    });
    its('ofo', function() {
      return should(equal(this.instance.foo));
    });
    its('rab', function() {
      return should(equal(this.instance.bar));
    });
    return its('bra', function() {
      return should(equal(this.instance.bar));
    });
  });

  xdescribe(mixins.AlternateCase, function() {
    context('mixed in a class using camelCase', function() {
      given('testClass', function() {
        var TestClass;
        return TestClass = (function() {
          function TestClass() {}

          TestClass.extend(mixins.AlternateCase);

          TestClass.prototype.someProperty = true;

          TestClass.prototype.someMethod = function() {};

          TestClass.snakify();

          return TestClass;

        })();
      });
      subject('instance', function() {
        return new this.testClass;
      });
      its('some_property', function() {
        return should(exist);
      });
      return its('some_method', function() {
        return should(exist);
      });
    });
    return context('mixed in a class using snake_case', function() {
      given('testClass', function() {
        var TestClass;
        return TestClass = (function() {
          function TestClass() {}

          TestClass.extend(mixins.AlternateCase);

          TestClass.prototype.some_property = true;

          TestClass.prototype.some_method = function() {};

          TestClass.camelize();

          return TestClass;

        })();
      });
      subject('instance', function() {
        return new this.testClass;
      });
      its('some_property', function() {
        return should(exist);
      });
      return its('someMethod', function() {
        return should(exist);
      });
    });
  });

  xdescribe(mixins.Cloneable, function() {
    context('when called without arguments', function() {
      given('testClass', function() {
        var TestClass;
        return TestClass = (function() {
          TestClass.include(mixins.Cloneable());

          function TestClass(self) {
            this.self = self;
          }

          return TestClass;

        })();
      });
      given('instance', function() {
        return new this.testClass;
      });
      subject(function() {
        return this.instance.clone();
      });
      it(function() {
        return should(exist);
      });
      return its('self', function() {
        return should(be(this.instance));
      });
    });
    return context('when called with arguments', function() {
      given('testClass', function() {
        var TestClass;
        return TestClass = (function() {
          TestClass.include(mixins.Cloneable('a', 'b'));

          function TestClass(a, b) {
            this.a = a;
            this.b = b;
          }

          return TestClass;

        })();
      });
      given('instance', function() {
        return new this.testClass(10, 'foo');
      });
      subject(function() {
        return this.instance.clone();
      });
      return it(function() {
        return should(equal(this.instance));
      });
    });
  });

  xdescribe(mixins.Delegation, function() {
    return context('on a class to delegate properties', function() {
      given('testClass', function() {
        var TestClass;
        return TestClass = (function() {
          TestClass.extend(mixins.Delegation);

          TestClass.delegate('foo', 'bar', 'func', {
            to: 'subObject'
          });

          TestClass.delegate('baz', {
            to: 'subObject',
            prefix: true
          });

          TestClass.delegate('baz', {
            to: 'subObject',
            prefix: true,
            "case": 'snake'
          });

          function TestClass() {
            this.subObject = {
              foo: 'foo',
              bar: 'bar',
              baz: 'baz',
              func: function() {
                return this.foo;
              }
            };
          }

          return TestClass;

        })();
      });
      given('instance', function() {
        return new this.testClass;
      });
      context('accessing a delegated property', function() {
        specify(function() {
          return expect(this.instance.foo).to(equal('foo'));
        });
        specify(function() {
          return expect(this.instance.bar).to(equal('bar'));
        });
        context('that hold a function', function() {
          return context('calling the function', function() {
            return specify('should be bound to the delegated object', function() {
              return expect(this.instance.func()).to(equal('foo'));
            });
          });
        });
        return context('with prefix', function() {
          specify(function() {
            return expect(this.instance.subObjectBaz).to(equal('baz'));
          });
          return context('and snake case', function() {
            return specify(function() {
              return expect(this.instance.subObject_baz).to(equal('baz'));
            });
          });
        });
      });
      return context('writing on a delegated property', function() {
        before(function() {
          this.instance.foo = 'oof';
          return this.instance.bar = 'rab';
        });
        specify(function() {
          return expect(this.instance.foo).to(equal('oof'));
        });
        specify(function() {
          return expect(this.instance.bar).to(equal('rab'));
        });
        return context('with prefix', function() {
          before(function() {
            return this.instance.subObjectBaz = 'zab';
          });
          specify(function() {
            return expect(this.instance.subObjectBaz).to(equal('zab'));
          });
          return context('and snake case', function() {
            before(function() {
              return this.instance.subObject_baz = 'zab';
            });
            return specify(function() {
              return expect(this.instance.subObject_baz).to(equal('zab'));
            });
          });
        });
      });
    });
  });

  xdescribe(mixins.Equatable, function() {
    return describe('when called with a list of properties name', function() {
      given('testClass', function() {
        var TestClass;
        return TestClass = (function() {
          TestClass.include(mixins.Equatable('a', 'b'));

          function TestClass(a, b) {
            this.a = a;
            this.b = b;
          }

          return TestClass;

        })();
      });
      given('instance1', function() {
        return new this.testClass(1, 2);
      });
      given('instance2', function() {
        return new this.testClass(1, 2);
      });
      given('instance3', function() {
        return new this.testClass(2, 2);
      });
      specify('instance1.equals instance2', function() {
        return this.instance1.equals(this.instance2).should(be(true));
      });
      return specify('instance1.equals instance3', function() {
        return this.instance1.equals(this.instance3).should(be(false));
      });
    });
  });

  xdescribe(mixins.Formattable, function() {
    describe('when called with extra arguments', function() {
      given('testClass', function() {
        var TestClass;
        return TestClass = (function() {
          TestClass.include(mixins.Formattable('TestClass', 'a', 'b'));

          function TestClass(a, b) {
            this.a = a;
            this.b = b;
          }

          return TestClass;

        })();
      });
      given('instance', function() {
        return new this.testClass(5, 'foo');
      });
      subject(function() {
        return this.instance.toString();
      });
      return the('toString method return', function() {
        return should(equal('[TestClass(a=5, b=foo)]'));
      });
    });
    return describe('when called without extra arguments', function() {
      given('testClass', function() {
        var TestClass;
        return TestClass = (function() {
          function TestClass() {}

          TestClass.include(mixins.Formattable('TestClass'));

          return TestClass;

        })();
      });
      given('instance', function() {
        return new this.testClass;
      });
      subject(function() {
        return this.instance.toString();
      });
      return the('toString method return', function() {
        return should(equal('[TestClass]'));
      });
    });
  });

  describe('a class without parent', function() {
    return describe('with many mixin included', function() {
      beforeEach(function() {
        var Dummy, MixinA, MixinB;
        MixinA = (function() {
          function MixinA() {}

          MixinA.prototype.get = function() {
            return 'mixin A get';
          };

          return MixinA;

        })();
        MixinB = (function() {
          function MixinB() {}

          MixinB.prototype.get = function() {
            return this["super"]() + ', mixin B get';
          };

          return MixinB;

        })();
        Dummy = (function() {
          function Dummy() {}

          Dummy.include(MixinA);

          Dummy.include(MixinB);

          Dummy.prototype.get = function() {
            return this["super"]() + ', dummy get';
          };

          return Dummy;

        })();
        return this.instance = new Dummy;
      });
      return it('calls the mixins super method in order', function() {
        return expect(this.instance.get()).toEqual('mixin A get, mixin B get, dummy get');
      });
    });
  });

  describe('a class with a parent', function() {
    describe('with several mixins', function() {
      beforeEach(function() {
        var AncestorClass, ChildClassA, ChildClassB, MixinA, MixinB, _ref, _ref1;
        this.ancestorClass = AncestorClass = (function() {
          function AncestorClass() {}

          AncestorClass.prototype.get = function() {
            return 'ancestor get';
          };

          return AncestorClass;

        })();
        this.mixinA = MixinA = (function() {
          function MixinA() {}

          MixinA.prototype.get = function() {
            return this["super"]() + ', mixin A get';
          };

          return MixinA;

        })();
        this.mixinB = MixinB = (function() {
          function MixinB() {}

          MixinB.prototype.get = function() {
            return this["super"]() + ', mixin B get';
          };

          return MixinB;

        })();
        ChildClassA = (function(_super) {
          __extends(ChildClassA, _super);

          function ChildClassA() {
            _ref = ChildClassA.__super__.constructor.apply(this, arguments);
            return _ref;
          }

          ChildClassA.include(MixinA);

          ChildClassA.include(MixinB);

          ChildClassA.prototype.get = function() {
            return this["super"]() + ', child get';
          };

          return ChildClassA;

        })(AncestorClass);
        ChildClassB = (function(_super) {
          __extends(ChildClassB, _super);

          function ChildClassB() {
            _ref1 = ChildClassB.__super__.constructor.apply(this, arguments);
            return _ref1;
          }

          ChildClassB.include(MixinB);

          ChildClassB.include(MixinA);

          return ChildClassB;

        })(AncestorClass);
        this.instanceA = new ChildClassA;
        return this.instanceB = new ChildClassB;
      });
      describe('that overrides the mixin method', function() {
        return it('calls the child and mixins methods up to the ancestor', function() {
          return expect(this.instanceA.get()).toEqual('ancestor get, mixin A get, mixin B get, child get');
        });
      });
      describe('that do not overrides the mixin method', function() {
        return it('calls the last mixin method and up to the ancestor class', function() {
          return expect(this.instanceB.get()).toEqual('ancestor get, mixin B get, mixin A get');
        });
      });
      describe('when a mixin was included more than once', function() {
        return it('does not mix up the mixin hierarchy', function() {
          expect(this.instanceA.get()).toEqual('ancestor get, mixin A get, mixin B get, child get');
          return expect(this.instanceB.get()).toEqual('ancestor get, mixin B get, mixin A get');
        });
      });
      return describe('calling this.super in a child method without super', function() {
        beforeEach(function() {
          var ChildClass, ancestor, mixinA, _ref;
          ancestor = this.ancestorClass;
          mixinA = this.mixinA;
          ChildClass = (function(_super) {
            __extends(ChildClass, _super);

            function ChildClass() {
              _ref = ChildClass.__super__.constructor.apply(this, arguments);
              return _ref;
            }

            ChildClass.include(mixinA);

            ChildClass.prototype.foo = function() {
              return this["super"]();
            };

            return ChildClass;

          })(ancestor);
          return this.instance = new ChildClass;
        });
        return it('raises an exception', function() {
          return expect(function() {
            return this.instance.foo();
          }).toThrow();
        });
      });
    });
    describe('that have a virtual property', function() {
      beforeEach(function() {
        var AncestorClass, Mixin, TestClass, _ref;
        AncestorClass = (function() {
          function AncestorClass() {}

          AncestorClass.accessor('foo', {
            get: function() {
              return this.__foo;
            },
            set: function(value) {
              return this.__foo = value;
            }
          });

          return AncestorClass;

        })();
        Mixin = (function() {
          function Mixin() {}

          Mixin.accessor('foo', {
            get: function() {
              return this["super"]() + ', in mixin';
            },
            set: function(value) {
              return this["super"](value);
            }
          });

          return Mixin;

        })();
        TestClass = (function(_super) {
          __extends(TestClass, _super);

          function TestClass() {
            _ref = TestClass.__super__.constructor.apply(this, arguments);
            return _ref;
          }

          TestClass.include(Mixin);

          TestClass.accessor('foo', {
            get: function() {
              return this["super"]() + ', in child class';
            },
            set: function(value) {
              return this["super"](value);
            }
          });

          return TestClass;

        })(AncestorClass);
        this.instance = new TestClass;
        return this.instance.foo = 'bar';
      });
      return it('calls the corresponding super accessor method', function() {
        return expect(this.instance.foo).toEqual('bar, in mixin, in child class');
      });
    });
    describe('that have a partially defined virtual property', function() {
      beforeEach(function() {
        var AncestorClass, Mixin, TestClass, _ref;
        AncestorClass = (function() {
          function AncestorClass() {}

          AncestorClass.accessor('foo', {
            set: function(value) {
              return this.__foo = value;
            }
          });

          return AncestorClass;

        })();
        Mixin = (function() {
          function Mixin() {}

          Mixin.accessor('foo', {
            get: function() {
              return this.__foo + ', in mixin';
            }
          });

          return Mixin;

        })();
        TestClass = (function(_super) {
          __extends(TestClass, _super);

          function TestClass() {
            _ref = TestClass.__super__.constructor.apply(this, arguments);
            return _ref;
          }

          TestClass.include(Mixin);

          TestClass.accessor('foo', {
            get: function() {
              return this["super"]() + ', in child class';
            },
            set: function(value) {
              return this["super"](value);
            }
          });

          return TestClass;

        })(AncestorClass);
        this.instance = new TestClass;
        return this.instance.foo = 'bar';
      });
      return it('creates a new accessor mixing the parent setter and the mixed getter', function() {
        return expect(this.instance.foo).toEqual('bar, in mixin, in child class');
      });
    });
    return describe('and a mixin with a class method override', function() {
      beforeEach(function() {
        var AncestorClass, MixinA, MixinB, _ref;
        AncestorClass = (function() {
          function AncestorClass() {}

          AncestorClass.get = function() {
            return 'bar';
          };

          return AncestorClass;

        })();
        MixinA = (function() {
          function MixinA() {}

          MixinA.get = function() {
            return this["super"]() + ', in mixin A get';
          };

          return MixinA;

        })();
        MixinB = (function() {
          function MixinB() {}

          MixinB.get = function() {
            return this["super"]() + ', in mixin B get';
          };

          return MixinB;

        })();
        return this.TestClass = (function(_super) {
          __extends(TestClass, _super);

          function TestClass() {
            _ref = TestClass.__super__.constructor.apply(this, arguments);
            return _ref;
          }

          TestClass.extend(MixinA);

          TestClass.extend(MixinB);

          TestClass.get = function() {
            return this["super"]() + ', in child get';
          };

          return TestClass;

        })(AncestorClass);
      });
      return it('calls the super class method from mixins up to the ancestor class', function() {
        return expect(this.TestClass.get()).toEqual('bar, in mixin A get, in mixin B get, in child get');
      });
    });
  });

  xdescribe(mixins.Globalizable, function() {
    given('testClass', function() {
      var TestClass;
      return TestClass = (function() {
        function TestClass() {}

        TestClass.include(mixins.Globalizable(spectacular.global));

        TestClass.prototype.globalizable = ['method'];

        TestClass.prototype.property = 'foo';

        TestClass.prototype.method = function() {
          return this.property;
        };

        return TestClass;

      })();
    });
    given('instance', function() {
      return new this.testClass;
    });
    return context('when globalized', function() {
      before(function() {
        return this.instance.globalize();
      });
      after(function() {
        return this.instance.unglobalize();
      });
      specify('the globalized method', function() {
        return expect(method()).to(equal('foo'));
      });
      return whenPass(function() {
        return context('and then unglobalized', function() {
          before(function() {
            return this.instance.unglobalize();
          });
          return specify('the unglobalized method', function() {
            return expect(typeof method).to(equal('undefined'));
          });
        });
      });
    });
  });

  xdescribe(mixins.HasAncestors, function() {
    given('testClass', function() {
      var TestClass;
      return TestClass = (function() {
        TestClass.concern(mixins.HasAncestors({
          through: 'customParent'
        }));

        function TestClass(name, customParent) {
          this.name = name;
          this.customParent = customParent;
        }

        TestClass.prototype.toString = function() {
          return 'instance ' + this.name;
        };

        return TestClass;

      })();
    });
    given('instanceA', function() {
      return new this.testClass('a');
    });
    given('instanceB', function() {
      return new this.testClass('b', this.instanceA);
    });
    given('instanceC', function() {
      return new this.testClass('c', this.instanceB);
    });
    describe('#ancestors', function() {
      subject(function() {
        return String(this.instanceC.ancestors);
      });
      return it(function() {
        return should(equal('instance b,instance a'));
      });
    });
    describe('#selfAndAncestors', function() {
      subject(function() {
        return String(this.instanceC.selfAndAncestors);
      });
      return it(function() {
        return should(equal('instance c,instance b,instance a'));
      });
    });
    return describe('.ancestorsScope', function() {
      before(function() {
        return this.testClass.ancestorsScope('isB', function(p) {
          return p.name === 'b';
        });
      });
      subject(function() {
        return String(this.instanceC.isB);
      });
      return it(function() {
        return should(equal('instance b'));
      });
    });
  });

  xdescribe(mixins.HasCollection, function() {
    given('testClass', function() {
      var TestClass;
      return TestClass = (function() {
        TestClass.concern(mixins.HasCollection('customChildren', 'customChild'));

        function TestClass(name, customChildren) {
          this.name = name;
          this.customChildren = customChildren != null ? customChildren : [];
        }

        return TestClass;

      })();
    });
    given('instanceRoot', function() {
      return new this.testClass('root');
    });
    given('instanceA', function() {
      return new this.testClass('a');
    });
    given('instanceB', function() {
      return new this.testClass('b');
    });
    before(function() {
      this.instanceRoot.customChildren.push(this.instanceA);
      return this.instanceRoot.customChildren.push(this.instanceB);
    });
    return context('included in class TestClass', function() {
      subject(function() {
        return this.instanceRoot;
      });
      its('customChildrenSize', function() {
        return should(equal(2));
      });
      its('customChildrenLength', function() {
        return should(equal(2));
      });
      its('customChildrenCount', function() {
        return should(equal(2));
      });
      context('using the generated customChildrenScope method', function() {
        before(function() {
          return this.testClass.customChildrenScope('childrenNamedB', function(child) {
            return child.name === 'b';
          });
        });
        return its('childrenNamedB', function() {
          return should(equal([this.instanceB]));
        });
      });
      context('adding a child using addCustomChild', function() {
        given('instanceC', function() {
          return new this.testClass('c');
        });
        before(function() {
          return this.instanceRoot.addCustomChild(this.instanceC);
        });
        its('customChildrenSize', function() {
          return should(equal(3));
        });
        return context('a second time', function() {
          before(function() {
            return this.instanceRoot.addCustomChild(this.instanceC);
          });
          return its('customChildrenSize', function() {
            return should(equal(3));
          });
        });
      });
      context('removing a child with removeCustomChild', function() {
        before(function() {
          return this.instanceRoot.removeCustomChild(this.instanceB);
        });
        return its('customChildrenSize', function() {
          return should(equal(1));
        });
      });
      return context('finding a child with findCustomChild', function() {
        subject(function() {
          return this.instanceRoot.findCustomChild(this.instanceB);
        });
        it(function() {
          return should(equal(1));
        });
        return context('that is not present', function() {
          given('instanceC', function() {
            return new this.testClass('c');
          });
          subject(function() {
            return this.instanceRoot.findCustomChild(this.instanceC);
          });
          return it(function() {
            return should(equal(-1));
          });
        });
      });
    });
  });

  xdescribe(mixins.HasNestedCollection, function() {
    given('testClass', function() {
      var TestClass;
      return TestClass = (function() {
        TestClass.concern(mixins.HasCollection('children', 'child'));

        TestClass.concern(mixins.HasNestedCollection('descendants', {
          through: 'children'
        }));

        function TestClass(name, children) {
          this.name = name;
          this.children = children != null ? children : [];
        }

        return TestClass;

      })();
    });
    given('instanceRoot', function() {
      return new this.testClass('root');
    });
    given('instanceA', function() {
      return new this.testClass('a');
    });
    given('instanceB', function() {
      return new this.testClass('b');
    });
    given('instanceC', function() {
      return new this.testClass('c');
    });
    before(function() {
      this.instanceRoot.addChild(this.instanceA);
      this.instanceRoot.addChild(this.instanceB);
      return this.instanceA.addChild(this.instanceC);
    });
    subject(function() {
      return this.instanceRoot;
    });
    its('descendants', function() {
      return should(equal([this.instanceA, this.instanceC, this.instanceB]));
    });
    return context('using the descendantsScope method', function() {
      before(function() {
        return this.testClass.descendantsScope('descendantsNamedB', function(item) {
          return item.name === 'b';
        });
      });
      return its('descendantsNamedB', function() {
        return should(equal([this.instanceB]));
      });
    });
  });

  xdescribe(mixins.Memoizable, function() {
    given('testClass', function() {
      var TestClass;
      return TestClass = (function() {
        TestClass.include(mixins.Memoizable);

        function TestClass(a, b) {
          this.a = a != null ? a : 10;
          this.b = b != null ? b : 20;
        }

        TestClass.prototype.getObject = function() {
          var object;
          if (this.memoized('getObject')) {
            return this.memoFor('getObject');
          }
          object = {
            a: this.a,
            b: this.b,
            c: this.a + this.b
          };
          return this.memoize('getObject', object);
        };

        TestClass.prototype.memoizationKey = function() {
          return "" + this.a + ";" + this.b;
        };

        return TestClass;

      })();
    });
    subject('instance', function() {
      return new this.testClass;
    });
    given('initial', function() {
      return this.instance.getObject();
    });
    given('secondCall', function() {
      return this.instance.getObject();
    });
    specify('the second object', function() {
      return this.secondCall.should(be(this.initial));
    });
    return context('when changing a property of the objet', function() {
      before(function() {
        this.initial;
        return this.instance.a = 20;
      });
      given('secondCall', function() {
        return this.instance.getObject();
      });
      return specify('the second object', function() {
        return this.secondCall.shouldnt(equal(this.initial));
      });
    });
  });

  xdescribe(mixins.Poolable, function() {
    given('testClass', function() {
      var PoolableClass;
      return PoolableClass = (function() {
        function PoolableClass() {}

        PoolableClass.concern(mixins.Poolable);

        return PoolableClass;

      })();
    });
    return context('requesting two instances', function() {
      before(function() {
        this.instance1 = this.testClass.get({
          x: 10,
          y: 20
        });
        return this.instance2 = this.testClass.get({
          x: 20,
          y: 10
        });
      });
      specify('the used instances count', function() {
        return this.testClass.usedInstances.length.should(equal(2));
      });
      return context('then disposing an instance', function() {
        before(function() {
          return this.instance2.dispose();
        });
        specify('the used instances count', function() {
          return this.testClass.usedInstances.length.should(equal(1));
        });
        specify('the unused instances count', function() {
          return this.testClass.unusedInstances.length.should(equal(1));
        });
        return context('then requesting another instance', function() {
          before(function() {
            return this.instance3 = this.testClass.get({
              x: 200,
              y: 100
            });
          });
          specify('the used instances count', function() {
            return this.testClass.usedInstances.length.should(equal(2));
          });
          specify('the returned instance', function() {
            return this.instance3.should(be(this.instance2));
          });
          return context('then disposing all the instances', function() {
            before(function() {
              this.instance1.dispose();
              return this.instance3.dispose();
            });
            specify('the used instances count', function() {
              return this.testClass.usedInstances.length.should(equal(0));
            });
            return specify('the unused instances count', function() {
              return this.testClass.unusedInstances.length.should(equal(2));
            });
          });
        });
      });
    });
  });

  xdescribe('Sourcable', function() {
    given('testClass1', function() {
      var TestClass1;
      return TestClass1 = (function() {
        TestClass1.include(mixins.Sourcable('TestClass1', 'a', 'b'));

        function TestClass1(a, b) {
          this.a = a;
          this.b = b;
        }

        return TestClass1;

      })();
    });
    given('testClass2', function() {
      var TestClass2;
      return TestClass2 = (function() {
        TestClass2.include(mixins.Sourcable('TestClass2', 'a', 'b'));

        function TestClass2(a, b) {
          this.a = a;
          this.b = b;
        }

        return TestClass2;

      })();
    });
    given('instance', function() {
      return new this.testClass2([10, "o'foo"], new this.testClass1(10, 5));
    });
    subject(function() {
      return this.instance.toSource();
    });
    return the('toSource method return', function() {
      return should(equal("new TestClass2([10,'o\\'foo'],new TestClass1(10,5))"));
    });
  });

}).call(this);

/*
//@ sourceMappingURL=mixins.spec.js.map
*/