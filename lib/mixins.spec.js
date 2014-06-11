(function() {
  var mixins,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if (typeof module === 'undefined') {
    mixins = window.mixins;
  } else {
    global.mixins = mixins = require('../../lib/mixins');
  }

  describe('mixins.Activable', function() {
    return describe('when included in a class', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          function TestClass() {}

          TestClass.include(mixins.Activable);

          TestClass.prototype.activated = function() {};

          TestClass.prototype.deactivated = function() {};

          return TestClass;

        })();
        this.instance = new TestClass;
        spyOn(this.instance, 'activated');
        return spyOn(this.instance, 'deactivated');
      });
      it('creates deactivated instances', function() {
        return expect(this.instance.active).toBeFalsy();
      });
      return describe('calling the activate method', function() {
        beforeEach(function() {
          return this.instance.activate();
        });
        it('activates the instance', function() {
          return expect(this.instance.active).toBeTruthy();
        });
        it('calls the activated hook', function() {
          return expect(this.instance.activated).toHaveBeenCalled();
        });
        return describe('then deactivated', function() {
          beforeEach(function() {
            return this.instance.deactivate();
          });
          it('deactivates the instance', function() {
            return expect(this.instance.active).toBeFalsy();
          });
          return it('calls the deactivated hook', function() {
            return expect(this.instance.deactivated).toHaveBeenCalled();
          });
        });
      });
    });
  });

  describe('mixins.Aliasable', function() {
    beforeEach(function() {
      var TestClass;
      TestClass = (function() {
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
      return this.instance = new TestClass;
    });
    return it('creates aliases for object properties', function() {
      expect(this.instance.oof).toEqual(this.instance.foo);
      expect(this.instance.ofo).toEqual(this.instance.foo);
      expect(this.instance.rab).toEqual(this.instance.bar);
      return expect(this.instance.bra).toEqual(this.instance.bar);
    });
  });

  describe('mixins.AlternateCase', function() {
    describe('mixed in a class using camelCase', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          function TestClass() {}

          TestClass.extend(mixins.AlternateCase);

          TestClass.prototype.someProperty = true;

          TestClass.prototype.someMethod = function() {};

          TestClass.snakify();

          return TestClass;

        })();
        return this.instance = new TestClass;
      });
      return it('creates properties with snake case', function() {
        expect(this.instance.some_property).toBeDefined();
        return expect(this.instance.some_method).toBeDefined();
      });
    });
    return describe('mixed in a class using snake_case', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          function TestClass() {}

          TestClass.extend(mixins.AlternateCase);

          TestClass.prototype.some_property = true;

          TestClass.prototype.some_method = function() {};

          TestClass.camelize();

          return TestClass;

        })();
        return this.instance = new TestClass;
      });
      return it('creates properties with camel case', function() {
        expect(this.instance.some_property).toBeDefined();
        return expect(this.instance.someMethod).toBeDefined();
      });
    });
  });

  describe('mixins.Cloneable', function() {
    describe('when called without arguments', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          TestClass.include(mixins.Cloneable());

          function TestClass(self) {
            this.self = self;
          }

          return TestClass;

        })();
        return this.instance = new TestClass;
      });
      return it('creates a copy by passing the reference in the copy constructor', function() {
        var clone;
        clone = this.instance.clone();
        expect(clone).toBeDefined();
        return expect(clone.self).toBe(this.instance);
      });
    });
    return describe('when called with arguments', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          TestClass.include(mixins.Cloneable('a', 'b'));

          function TestClass(a, b) {
            this.a = a;
            this.b = b;
          }

          return TestClass;

        })();
        return this.instance = new TestClass(10, 'foo');
      });
      return it('creates a copy of the object', function() {
        var clone;
        clone = this.instance.clone();
        expect(clone).toBeDefined();
        expect(clone).toEqual(this.instance);
        return expect(clone).not.toBe(this.instance);
      });
    });
  });

  describe('mixins.Delegation', function() {
    return describe('included in a class with delegated properties', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
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
        return this.instance = new TestClass;
      });
      describe('when accessing a delegated property', function() {
        it('returns the composed instance value', function() {
          expect(this.instance.foo).toEqual('foo');
          return expect(this.instance.bar).toEqual('bar');
        });
        describe('that hold a function', function() {
          return describe('calling the function', function() {
            return it('binds the methods to the delegated object', function() {
              return expect(this.instance.func()).toEqual('foo');
            });
          });
        });
        return describe('with prefix', function() {
          it('returns the composed instance value', function() {
            return expect(this.instance.subObjectBaz).toEqual('baz');
          });
          return describe('and snake case', function() {
            return it('returns the composed instance value', function() {
              return expect(this.instance.subObject_baz).toEqual('baz');
            });
          });
        });
      });
      return describe('writing on a delegated property', function() {
        beforeEach(function() {
          this.instance.foo = 'oof';
          return this.instance.bar = 'rab';
        });
        it('writes in the composed instance properties', function() {
          expect(this.instance.foo).toEqual('oof');
          return expect(this.instance.bar).toEqual('rab');
        });
        return describe('with prefix', function() {
          beforeEach(function() {
            return this.instance.subObjectBaz = 'zab';
          });
          it('writes in the composed instance properties', function() {
            return expect(this.instance.subObjectBaz).toEqual('zab');
          });
          return describe('and snake case', function() {
            beforeEach(function() {
              return this.instance.subObject_baz = 'zab';
            });
            return it('writes in the composed instance properties', function() {
              return expect(this.instance.subObject_baz).toEqual('zab');
            });
          });
        });
      });
    });
  });

  describe('mixins.Equatable', function() {
    return describe('when called with a list of properties name', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          TestClass.include(mixins.Equatable('a', 'b'));

          function TestClass(a, b) {
            this.a = a;
            this.b = b;
          }

          return TestClass;

        })();
        this.instance1 = new TestClass(1, 2);
        this.instance2 = new TestClass(1, 2);
        return this.instance3 = new TestClass(2, 2);
      });
      it('returns true with two similar instancew', function() {
        return expect(this.instance1.equals(this.instance2)).toBeTruthy();
      });
      return it('returns false with tow different instances', function() {
        return expect(this.instance1.equals(this.instance3)).toBeFalsy();
      });
    });
  });

  describe('mixins.Formattable', function() {
    describe('when called with extra arguments', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          TestClass.include(mixins.Formattable('TestClass', 'a', 'b'));

          function TestClass(a, b) {
            this.a = a;
            this.b = b;
          }

          return TestClass;

        })();
        return this.instance = new TestClass(5, 'foo');
      });
      return it('returns a formatted string with extra details', function() {
        return expect(this.instance.toString()).toEqual('[TestClass(a=5, b=foo)]');
      });
    });
    return describe('when called without extra arguments', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          function TestClass() {}

          TestClass.include(mixins.Formattable('TestClass'));

          return TestClass;

        })();
        return this.instance = new TestClass;
      });
      return it('returns a formatted string without any details', function() {
        return expect(this.instance.toString()).toEqual('[TestClass]');
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
    describe('with no mixins', function() {
      beforeEach(function() {
        var AncestorClass, Dummy;
        AncestorClass = (function() {
          function AncestorClass() {}

          AncestorClass.prototype.get = function() {
            return 'ancestor get';
          };

          return AncestorClass;

        })();
        Dummy = (function(_super) {
          __extends(Dummy, _super);

          function Dummy() {
            return Dummy.__super__.constructor.apply(this, arguments);
          }

          Dummy.prototype.get = function() {
            return this["super"]() + ', child get';
          };

          return Dummy;

        })(AncestorClass);
        return this.instance = new Dummy;
      });
      return it('calls the ancestor method', function() {
        return expect(this.instance.get()).toEqual('ancestor get, child get');
      });
    });
    describe('with several mixins', function() {
      beforeEach(function() {
        var AncestorClass, ChildClassA, ChildClassB, MixinA, MixinB;
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
            return ChildClassA.__super__.constructor.apply(this, arguments);
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
            return ChildClassB.__super__.constructor.apply(this, arguments);
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
          var ChildClass, ancestor, mixinA;
          ancestor = this.ancestorClass;
          mixinA = this.mixinA;
          ChildClass = (function(_super) {
            __extends(ChildClass, _super);

            function ChildClass() {
              return ChildClass.__super__.constructor.apply(this, arguments);
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
        var AncestorClass, Mixin, TestClass;
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
            return TestClass.__super__.constructor.apply(this, arguments);
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
        var AncestorClass, Mixin, TestClass;
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
            return TestClass.__super__.constructor.apply(this, arguments);
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
        var AncestorClass, MixinA, MixinB;
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
            return TestClass.__super__.constructor.apply(this, arguments);
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

  describe('mixins.Globalizable', function() {
    beforeEach(function() {
      var TestClass;
      TestClass = (function() {
        function TestClass() {}

        TestClass.include(mixins.Globalizable(typeof global !== "undefined" && global !== null ? global : window));

        TestClass.prototype.globalizable = ['method'];

        TestClass.prototype.property = 'foo';

        TestClass.prototype.method = function() {
          return this.property;
        };

        return TestClass;

      })();
      return this.instance = new TestClass;
    });
    return describe('when globalized', function() {
      beforeEach(function() {
        return this.instance.globalize();
      });
      afterEach(function() {
        return this.instance.unglobalize();
      });
      it('creates methods on the global object', function() {
        return expect(method()).toEqual('foo');
      });
      return describe('and then unglobalized', function() {
        beforeEach(function() {
          return this.instance.unglobalize();
        });
        return it('removes the methods from the global object', function() {
          return expect(typeof method).toEqual('undefined');
        });
      });
    });
  });

  describe('mixins.HasAncestors', function() {
    beforeEach(function() {
      var TestClass;
      this.testClass = TestClass = (function() {
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
      this.instanceA = new TestClass('a');
      this.instanceB = new TestClass('b', this.instanceA);
      return this.instanceC = new TestClass('c', this.instanceB);
    });
    describe('#ancestors', function() {
      return it('returns an array of the object ancestors', function() {
        return expect(this.instanceC.ancestors).toEqual([this.instanceB, this.instanceA]);
      });
    });
    describe('#selfAndAncestors', function() {
      return it('returns an array of the object and its ancestors', function() {
        return expect(this.instanceC.selfAndAncestors).toEqual([this.instanceC, this.instanceB, this.instanceA]);
      });
    });
    return describe('.ancestorsScope', function() {
      beforeEach(function() {
        return this.testClass.ancestorsScope('isB', function(p) {
          return p.name === 'b';
        });
      });
      return it('should creates a scope filtering the ancestors', function() {
        return expect(this.instanceC.isB).toEqual([this.instanceB]);
      });
    });
  });

  describe('mixins.HasCollection', function() {
    beforeEach(function() {
      var TestClass;
      this.testClass = TestClass = (function() {
        TestClass.concern(mixins.HasCollection('customChildren', 'customChild'));

        function TestClass(name, customChildren) {
          this.name = name;
          this.customChildren = customChildren != null ? customChildren : [];
        }

        return TestClass;

      })();
      this.instanceRoot = new TestClass('root');
      this.instanceA = new TestClass('a');
      this.instanceB = new TestClass('b');
      this.instanceRoot.customChildren.push(this.instanceA);
      return this.instanceRoot.customChildren.push(this.instanceB);
    });
    return describe('included in class TestClass', function() {
      it('provides properties to count children', function() {
        expect(this.instanceRoot.customChildrenSize).toEqual(2);
        expect(this.instanceRoot.customChildrenLength).toEqual(2);
        return expect(this.instanceRoot.customChildrenCount).toEqual(2);
      });
      describe('using the generated customChildrenScope method', function() {
        beforeEach(function() {
          return this.testClass.customChildrenScope('childrenNamedB', function(child) {
            return child.name === 'b';
          });
        });
        return it('creates a property returning a filtered array of children', function() {
          return expect(this.instanceRoot.childrenNamedB).toEqual([this.instanceB]);
        });
      });
      describe('adding a child using addCustomChild', function() {
        beforeEach(function() {
          this.instanceC = new this.testClass('c');
          return this.instanceRoot.addCustomChild(this.instanceC);
        });
        it('updates the children count', function() {
          return expect(this.instanceRoot.customChildrenSize).toEqual(3);
        });
        return describe('a second time', function() {
          beforeEach(function() {
            return this.instanceRoot.addCustomChild(this.instanceC);
          });
          return it('does not add the instance', function() {
            return expect(this.instanceRoot.customChildrenSize).toEqual(3);
          });
        });
      });
      describe('removing a child with removeCustomChild', function() {
        beforeEach(function() {
          return this.instanceRoot.removeCustomChild(this.instanceB);
        });
        return it('removes the child', function() {
          return expect(this.instanceRoot.customChildrenSize).toEqual(1);
        });
      });
      return describe('finding a child with findCustomChild', function() {
        it('returns the index of the child', function() {
          return expect(this.instanceRoot.findCustomChild(this.instanceB)).toEqual(1);
        });
        return describe('that is not present', function() {
          beforeEach(function() {
            return this.instanceC = new this.testClass('c');
          });
          return it('returns -1', function() {
            return expect(this.instanceRoot.findCustomChild(this.instanceC)).toEqual(-1);
          });
        });
      });
    });
  });

  describe('mixins.HasNestedCollection', function() {
    beforeEach(function() {
      var TestClass;
      this.testClass = TestClass = (function() {
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
      this.instanceRoot = new this.testClass('root');
      this.instanceA = new this.testClass('a');
      this.instanceB = new this.testClass('b');
      this.instanceC = new this.testClass('c');
      this.instanceRoot.addChild(this.instanceA);
      this.instanceRoot.addChild(this.instanceB);
      return this.instanceA.addChild(this.instanceC);
    });
    it('returns all its descendants in a single array', function() {
      return expect(this.instanceRoot.descendants).toEqual([this.instanceA, this.instanceC, this.instanceB]);
    });
    return describe('using the descendantsScope method', function() {
      beforeEach(function() {
        return this.testClass.descendantsScope('descendantsNamedB', function(item) {
          return item.name === 'b';
        });
      });
      return it('creates a method returning a filtered array of descendants', function() {
        return expect(this.instanceRoot.descendantsNamedB).toEqual([this.instanceB]);
      });
    });
  });

  describe('mixins.Memoizable', function() {
    beforeEach(function() {
      var TestClass;
      this.testClass = TestClass = (function() {
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
      this.instance = new this.testClass;
      this.initial = this.instance.getObject();
      return this.secondCall = this.instance.getObject();
    });
    it('stores the result of the first call and return it in the second', function() {
      return expect(this.secondCall).toBe(this.initial);
    });
    return describe('when changing a property of the objet', function() {
      beforeEach(function() {
        return this.instance.a = 20;
      });
      return it('clears the memoized value', function() {
        return expect(this.instance.getObject()).not.toEqual(this.initial);
      });
    });
  });

  describe('mixins.Poolable', function() {
    beforeEach(function() {
      var PoolableClass;
      return this.testClass = PoolableClass = (function() {
        function PoolableClass() {}

        PoolableClass.concern(mixins.Poolable);

        return PoolableClass;

      })();
    });
    return describe('requesting two instances', function() {
      beforeEach(function() {
        this.instance1 = this.testClass.get({
          x: 10,
          y: 20
        });
        return this.instance2 = this.testClass.get({
          x: 20,
          y: 10
        });
      });
      it('creates two instances and returns them', function() {
        return expect(this.testClass.usedInstances.length).toEqual(2);
      });
      return describe('then disposing an instance', function() {
        beforeEach(function() {
          return this.instance2.dispose();
        });
        it('removes the instance from the used list', function() {
          return expect(this.testClass.usedInstances.length).toEqual(1);
        });
        it('adds the disposed instance in the unused list', function() {
          return expect(this.testClass.unusedInstances.length).toEqual(1);
        });
        return describe('then requesting another instance', function() {
          beforeEach(function() {
            return this.instance3 = this.testClass.get({
              x: 200,
              y: 100
            });
          });
          it('reuses a previously created instance', function() {
            expect(this.testClass.usedInstances.length).toEqual(2);
            expect(this.testClass.unusedInstances.length).toEqual(0);
            return expect(this.instance3).toBe(this.instance2);
          });
          return describe('then disposing all the instances', function() {
            beforeEach(function() {
              this.instance1.dispose();
              return this.instance3.dispose();
            });
            it('removes all the instances from the used list', function() {
              return expect(this.testClass.usedInstances.length).toEqual(0);
            });
            return it('adds these instances in the unused list', function() {
              return expect(this.testClass.unusedInstances.length).toEqual(2);
            });
          });
        });
      });
    });
  });

  describe('mixins.Sourcable', function() {
    beforeEach(function() {
      var TestClass1, TestClass2;
      this.testClass1 = TestClass1 = (function() {
        TestClass1.include(mixins.Sourcable('TestClass1', 'a', 'b'));

        function TestClass1(a, b) {
          this.a = a;
          this.b = b;
        }

        return TestClass1;

      })();
      this.testClass2 = TestClass2 = (function() {
        TestClass2.include(mixins.Sourcable('TestClass2', 'a', 'b'));

        function TestClass2(a, b) {
          this.a = a;
          this.b = b;
        }

        return TestClass2;

      })();
      return this.instance = new this.testClass2([10, "o'foo"], new this.testClass1(10, 5));
    });
    return it('returns the source of the object', function() {
      return expect(this.instance.toSource()).toEqual("new TestClass2([10,'o\\'foo'],new TestClass1(10,5))");
    });
  });

}).call(this);

//# sourceMappingURL=mixins.spec.js.map
